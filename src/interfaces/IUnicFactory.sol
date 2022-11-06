//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IUnicFactory {
    function deployERC1155(
        string memory _uri,
        uint256 _royalties
    ) external returns (address newERC1155);

    event ERC1155Deployed(
        address _contract,
        address _creator,
        string _uri,
        uint256 _royalties
    );

    error ZeroAddress();
}