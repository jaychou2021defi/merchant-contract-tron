// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Initializable.sol";
import "./OwnableUpgradeable.sol";

contract Merchant is Initializable, OwnableUpgradeable {

    mapping(address => MerchantInfo) public merchantMap;

    address[] public globalTokens;

    event AddMerchant(address merchant);

    address public immutable SETTLE_TOKEN;

    receive() payable external {}

    struct MerchantInfo {
        address account;
        address payable settleAccount;
        address settleCurrency;
        bool autoSettle;
        bool isFixedRate;
        address [] tokens;
    }

    constructor(address _settleToken){
        SETTLE_TOKEN = _settleToken;
    }

    function initialize()public initializer{
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function addMerchant(address payable _settleAccount, address _settleCurrency, bool _autoSettle, bool _isFixedRate, address[] memory _tokens) external {

        if(address(0) != _settleCurrency) {
            require(SETTLE_TOKEN == _settleCurrency);
        }

        if(_tokens.length > 0) {
            for(uint i = 0; i < _tokens.length; i++) {
                require(validatorGlobalToken(_tokens[i]));
            }
        }

        merchantMap[msg.sender] = MerchantInfo (msg.sender, _settleAccount, _settleCurrency, _autoSettle, _isFixedRate, _tokens);

        emit AddMerchant(msg.sender);

    }

    function setMerchantToken(address[] memory _tokens) external {
        require(_isMerchant(msg.sender));
        for (uint i = 0; i < _tokens.length; i++) {
            require(validatorGlobalToken(_tokens[i]));
        }
        merchantMap[msg.sender].tokens = _tokens;
    }

    function setSettleCurrency(address payable _currency) external {
        require(_isMerchant(msg.sender));
        merchantMap[msg.sender].settleCurrency = _currency;
    }

    function setSettleAccount(address payable _account) external {
        require(_isMerchant(msg.sender));
        merchantMap[msg.sender].settleAccount = _account;
    }

    function setAutoSettle(bool _autoSettle) external {
        require(_isMerchant(msg.sender));
        merchantMap[msg.sender].autoSettle = _autoSettle;
    }

    function setFixedRate(bool _fixedRate) external{
        require(_isMerchant(msg.sender));
        merchantMap[msg.sender].isFixedRate = _fixedRate;
    }


    function isMerchant(address _merchant) external view returns(bool) {
        return _isMerchant(_merchant);
    }

    function _isMerchant(address _merchant) public view returns(bool) {
        return merchantMap[_merchant].account != address(0);
    }


    function getMerchantTokens(address _merchant) external view returns(address[] memory) {
        return merchantMap[_merchant].tokens;
    }

    function getSettleCurrency(address _merchant) external view returns (address) {
        return merchantMap[_merchant].settleCurrency;
    }

    function getSettleAccount(address _merchant) external view returns(address) {
        return merchantMap[_merchant].settleAccount;
    }

    function getAutoSettle(address _merchant) external view returns (bool){
        return merchantMap[_merchant].autoSettle;
    }

    function getFixedRate(address _merchant) external view returns(bool) {
        return merchantMap[_merchant].isFixedRate;
    }

    function getGlobalTokens() public view returns(address[] memory){
        return globalTokens;
    }

    function setGlobalTokens(address[] memory _tokens) external onlyOwner{
        globalTokens = _tokens;
    }

    function validatorCurrency(address _merchant, address _currency) public view returns (bool){
        for(uint idx = 0; idx < merchantMap[_merchant].tokens.length; idx ++) {
            if (_currency == merchantMap[_merchant].tokens[idx]) {
                return true;
            }
        }
        return false;
    }

    function validatorGlobalToken(address _token) public view returns (bool){
        for(uint idx = 0; idx < globalTokens.length; idx ++) {
            if (_token == globalTokens[idx]) {
                return true;
            }
        }
        return false;
    }

}

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}
