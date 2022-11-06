// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "../interfaces/IUnicMapper.sol";
import "./ApeTokenGuard.sol";

contract UnicMapper is IUnicMapper, Ownable, Pausable, ApeTokenGuard {
    uint256 public apeGuardMinimum = 10000;
    mapping(bytes32 => AssetInfo) public override idToAsset;

    function setApeGuardMinimum(uint256 _minimum) public {
        apeGuardMinimum = _minimum;
    }

    function setIdToAsset(bytes32 _id, bytes32 _chain, address _assetAddress, uint _tokenId) external override apeGuard(apeGuardMinimum) {
        if (idToAsset[_id].assetAddress != address(0)) revert AlreadySet();
        if (_assetAddress == address(0)) revert ZeroAddress();

        idToAsset[_id] = AssetInfo(_chain, _assetAddress, _tokenId);

        emit IDSet(_id, _chain, _assetAddress, _tokenId);
    }

    function setIdsToAssets(
        bytes32[] memory _ids,
        bytes32[] memory _chains,
        address[] memory _assetAddresses,
        uint[] memory _tokenIds
    ) external override apeGuard(apeGuardMinimum) {
        for (uint256 i; i < _ids.length;) {
            bytes32 _id = _ids[i];
            bytes32 _chain = _chains[i];
            address _assetAddress = _assetAddresses[i];
            uint _tokenId = _tokenIds[i];
            if (idToAsset[_id].assetAddress != address(0)) revert AlreadySet();
            if (_assetAddresses[i] == address(0)) revert ZeroAddress();

            idToAsset[_id] = AssetInfo(_chain, _assetAddress, _tokenId);

            emit IDSet(_id, _chain, _assetAddress, _tokenId);

            unchecked {
                ++i;
            }
        }
    }

    function setIdsToCollection(
        bytes32 _chain,
        address _assetAddress,
        bytes32[] memory _ids,
        uint[] memory _tokenIds
    ) external override apeGuard(apeGuardMinimum) {
        if (_assetAddress == address(0)) revert ZeroAddress();

        for (uint256 i; i < _ids.length;) {
            bytes32 _id = _ids[i];
            uint _tokenId = _tokenIds[i];
            if (idToAsset[_id].assetAddress != address(0)) revert AlreadySet();

            idToAsset[_id] = AssetInfo(_chain, _assetAddress, _tokenId);

            emit IDSet(_id, _chain, _assetAddress, _tokenId);

            unchecked {
                ++i;
            }
        }
    }
}