//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IUnicMapper {
    struct AssetInfo {
        bytes32 chain;
        address assetAddress;
        uint tokenId;
    }

    function idToAsset(bytes32) external view returns (bytes32, address, uint);

    function setIdToAsset(bytes32 _id, bytes32 _chain, address _assetAddress, uint _tokenId) external;

    function setIdsToAssets(bytes32[] memory _ids, bytes32[] memory _chains, address[] memory _assetAddresses, uint[] memory _tokenIds) external;

    function setIdsToCollection(
        bytes32 _chain,
        address _assetAddress,
        bytes32[] memory _ids,
        uint[] memory _tokenIds
    ) external;

    error AlreadySet();
    error ZeroAddress();

    event IDSet(bytes32 _id, bytes32 _chain, address _assetAddress, uint _tokenId);
}