// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract MyToken {
    string public name = "My Token";
    string public symbol = "MTK";
    uint256 public totalSupply = 1000000000000000000000000; // 1 million tokens
    uint8 public decimals = 18;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    constructor() {
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(
        address _to,
        uint256 _value
    ) public returns (bool success) {
        require(_to != address(0), "Invalid recipient address");
        require(
            balanceOf[msg.sender] >= _value,
            "'Transfer': Insufficient balance"
        );

        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;

        emit Transfer(msg.sender, _to, _value);

        return true;
    }

    function approve(
        address _spender,
        uint256 _value
    ) public returns (bool success) {
        require(_spender != address(0), "Invalid spender address");

        allowance[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;
    }

    function balanceOfAccount(
        address account
    ) public view virtual returns (uint256) {
        return balanceOf[account];
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        require(_to != address(0), "Invalid recipient address");
        require(balanceOf[_from] >= _value, "Insufficient balance");
        require(
            allowance[_from][msg.sender] >= _value,
            "Insufficient allowance"
        );

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, _value);

        return true;
    }
}

//