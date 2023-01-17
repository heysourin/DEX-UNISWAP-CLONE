// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Exchange is ERC20 {
    address public cryptoDevTokenAddress;

    //TODO: Exchange is inheriting ERC20, because our exchange would keep track of Crypto Dev LP tokens
    constructor(address _CryptoDevtoken) ERC20("CryptoDev LP Token", "CDLP") {
        require(
            _CryptoDevtoken != address(0),
            "Token address passed is a null address"
        );
        cryptoDevTokenAddress = _CryptoDevtoken;
    }

    //TODO: Getting balance of CryptoDev tokens in this CONTRACT.
    function getReserve() public view returns (uint) {
        return ERC20(cryptoDevTokenAddress).balanceOf(address(this));
    }

    //TODO: Lets create an 'addLiquidity' function which would add liquidity in the form of ETH and Crypto Dev tokens to our contract.

    function addLiquidity(uint _amount) public payable returns (uint) {
        uint liquidity;
        uint ethBalance = address(this).balance;
        uint cryptoDevTokenReserve = getReserve();
        ERC20 cryptoDevToken = ERC20(cryptoDevTokenAddress);

        if (cryptoDevTokenReserve == 0) {
            cryptoDevToken.transferFrom(msg.sender, address(this), _amount);
            liquidity = ethBalance; // As first time user
            _mint(msg.sender, liquidity); //Minting ethBalance amount of LP tokens to the USER.
        } else {
            uint ethReserve = ethBalance - msg.value;
            uint cryptoDevTokenAmount = (msg.value * cryptoDevTokenReserve) /
                (ethReserve);
            require(
                _amount >= cryptoDevTokenAmount,
                "Amount of tokens sent is less than the minimum tokens required"
            );
            cryptoDevToken.transferFrom(
                msg.sender,
                address(this),
                cryptoDevTokenAmount
            );
            liquidity = (totalSupply() * msg.value) / ethReserve;
            _mint(msg.sender, liquidity);
        }
        return liquidity;
    }

    //TODO:
    function removerLiquidity(uint _amount) public returns (uint, uint) {
        require(_amount > 0, "Amount should be greater than zero");
        uint ethReserve = address(this).balance;
        uint _totalSupply = totalSupply();

        uint ethAmount = (ethReserve * _amount) / totalSupply;
        uint cryptoDevTokenAmount = (getReserve() * _amount) / _totalSupply;
        _burn(msg.sender, _amount);
        payable(msg.sender).transfer(ethAmount);
        ERC20(cryptoDevTokenAddress).transfer(msg.sender, cryptoDevTokenAmount);
        return (ethAmount, cryptoDevTokenAmount);
    }

    //TODO:
    function getAmountOfTokens(
        uint256 inputAmount,
        uint256 inputReserve,
        uint256 outputReserve
    ) public pure returns (uint256) {
        require(inputReserve > 0 && outputReserve > 0, "invalid reserves");

        uint256 inputAmountWithFee = inputAmount * 99;

        uint256 numerator = inputAmountWithFee * outputReserve;
        uint256 denominator = (inputReserve * 100) + inputAmountWithFee;
        return numerator / denominator;
    }

    //TODO:
    function ethToCryptoDevToken(uint _minTokens) public payable {
        uint256 tokenReserve = getReserve();
        uint256 tokensBought = getAmountOfTokens(
            msg.value,
            address(this).balance - msg.value,
            tokenReserve
        );
        require(tokensBought >= _minTokens, "Insufficient output amount");
        ERC20(cryptoDevTokenAddress).transfer(msg.sender, tokensBought);
    }

    //TODO:
    function cryptoDevTokenToEth(uint _tokensSold, uint _minEth) public {
        uint256 tokenReserve = getReserve();
        uint256 ethBought = getAmountsOfTokens(
            _tokensSold,
            tokenReserve,
            address(this).balance
        );
        require(ethBought >= _minEth, "Insufficient output method");
        ERC20(cryptoDevTokenAddress).transferFrom(
            msg.sender,
            address(this).balance,
            _tokensSold
        );
        payable(msg.sender).transfer(ethBought);
    }
}
