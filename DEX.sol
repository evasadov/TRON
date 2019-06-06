pragma solidity ^0.4.24;

contract Token {
    mapping (address => uint256) public balanceOf;
    function transfer(address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
}

contract DEX
 {
     
    address public admin;

    mapping (address => mapping(address => uint256)) public _token;
    mapping (address => mapping(address => bool)) public access;
    mapping (address => bool) public ethaccess;


constructor() public
{
    admin = msg.sender;
}


function safeAdd(uint crtbal, uint depbal) public pure returns (uint)
{
    uint totalbal = crtbal + depbal;
    return totalbal;
}

function safeSub(uint crtbal, uint depbal) public pure returns (uint)
{
    uint totalbal = crtbal - depbal;
    return totalbal;
}

/// @notice View balance
/// @param token Token contract
/// @param user owner address
function balanceOf(address token,address user) public view returns(uint256)
{
    return Token(token).balanceOf(user);
}


/// @notice Token transfer
/// @param token Token contract
/// @param tokens value
function tokenTransfer(address token, uint256 tokens)public payable
{

    _token[msg.sender][token] = safeAdd(_token[msg.sender][token], tokens);
    Token(token).transferFrom(msg.sender,address(this), tokens);

}


function tokenallowance (address token,address to, uint256 tokens) public returns(bool){
    require(admin==msg.sender);
    if(access[to][token]==false){
        access[to][token]=true;
        return true;
    }
}
/// @notice Token withdraw
/// @param token Token contract
/// @param to Receiver address
/// @param tokens value
function tokenWithdraw(address token, address to, uint256 tokens)public payable
{
    require(access[to][token]==true);
    if(Token(token).balanceOf(address(this))>=tokens)
        {
            _token[msg.sender][token] = safeSub(_token[msg.sender][token] , tokens) ;
            Token(token).transfer(to, tokens);
        }
    
}

///@notice Token balance
///@param token Token contract
function contract_bal(address token) public view returns(uint256)
{
    return Token(token).balanceOf(address(this));
}

///@notice Deposit ETH
function depositETH() payable external
{

}

function ethallowance(address to,uint256 value) public returns (bool){
    require(admin==msg.sender);
    if(ethaccess[to]==false){
        ethaccess[to]=true;
        return true;
    }
}

///@notice Withdraw ETH
///@param to Receiver address
///@param value ethervalue
function withdrawETH(address to, uint256 value) public payable returns (bool)
{
    require(ethaccess[to]==true);
        to.transfer(value);
        return true;

}
}
