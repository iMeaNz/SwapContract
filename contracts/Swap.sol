// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "./IERC20.sol";
import "./IJoeRouter02.sol";
import "./Ownable.sol";

contract tokenSwap is Ownable {
    address private constant JOE_V2_ROUTER = 0x60aE616a2155Ee3d9A68541Ba4544862310933d4;
    address private constant WAVAX = 0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7;
    address private constant USDC = 0xA7D7079b0FEaD91F3e65f86E8915Cb59c1a4C664;

    function checkPath(
        address _tokenIn, 
        address _tokenOut
    ) internal pure returns (address[] memory) {
        address[] memory path;

        if (_tokenIn == WAVAX || _tokenOut == WAVAX) {
            path = new address[](2);
            path[0] = _tokenIn;
            path[1] = _tokenOut;
        } else {
            path = new address[](3);
            path[0] = _tokenIn;
            path[1] = WAVAX;
            path[2] = _tokenOut;
        }
    return path;
    }

    function getAmountOutMin(
        address _tokenIn, 
        address _tokenOut, 
        uint256 _amountIn
    ) internal view returns (uint256) {
        address[] memory path = checkPath(_tokenIn, _tokenOut);
        uint256[] memory amountOutMins = IJoeRouter02(JOE_V2_ROUTER).getAmountsOut(_amountIn, path);
        return amountOutMins[path.length -1];  
    }

    function swap(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn
    ) external onlyOwner {
        address[] memory path = checkPath(_tokenIn, _tokenOut);
        uint256 _amountOutMin = getAmountOutMin(_tokenIn, _tokenOut, _amountIn);

        IERC20(_tokenIn).transferFrom(msg.sender, address(this), _amountIn);
        IERC20(_tokenIn).approve(JOE_V2_ROUTER, _amountIn);
        IJoeRouter02(JOE_V2_ROUTER).swapExactTokensForTokens(
            _amountIn,
            _amountOutMin,
            path,
            msg.sender,
            block.timestamp);
    }

    function getBalanceOf(address _token, address _owner) external view returns (uint256) {
        return IERC20(_token).balanceOf(_owner);
    }
}