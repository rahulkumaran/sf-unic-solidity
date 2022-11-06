// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "../interfaces/IUnicERC1155.sol";
import "../utils/ERC2981Base.sol";

contract UnicERC1155 is IUnicERC1155, ERC1155, EIP712, ERC2981Base, Ownable, AccessControl {
    RoyaltyInfo private royalties;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    string private constant SIGNING_DOMAIN = "Unic-Voucher";
    string private constant SIGNATURE_VERSION = "1";

    mapping (address => uint256) pendingWithdrawals;

    constructor(string memory _uri, uint _royalties, address _creator) ERC1155(_uri) EIP712(SIGNING_DOMAIN, SIGNATURE_VERSION) {
        _setRoyalties(_creator, _royalties);
        _setupRole(MINTER_ROLE, _creator);
    }

    /// @notice Retuns the amount of Ether available to the caller to withdraw.
    function availableToWithdraw() public view returns (uint256) {
        return pendingWithdrawals[msg.sender];
    }

    function burn( address from, uint256 id, uint256 amount) public onlyOwner {
        if (msg.sender != from) revert NotOwner();
        _burn(from, id, amount);
    }

    function mint( address to, uint256 id, uint256 amount) public onlyOwner {
        _mint(to, id, amount, "");
    }

    /// @notice Redeems an NFTVoucher for an actual NFT, creating it in the process.
    /// @param redeemer The address of the account which will receive the NFT upon success.
    /// @param voucher A signed NFTVoucher that describes the NFT to be redeemed.
    function redeem(address redeemer, NFTVoucher calldata voucher) public payable returns (uint256) {
        // make sure signature is valid and get the address of the signer
        address signer = _verify(voucher);

        // make sure that the signer is authorized to mint NFTs
        if (!hasRole(MINTER_ROLE, signer)) revert InvalidSignature();

        // make sure that the redeemer is paying enough to cover the buyer's cost
        if (msg.value < voucher.minPrice) revert InsufficientFunds();

        // first assign the token to the signer, to establish provenance on-chain
        _mint(signer, voucher.tokenId, voucher.amount, "");

        // transfer the token to the redeemer
        _safeTransferFrom(signer, redeemer, voucher.tokenId, voucher.amount, "");

        // record payment to signer's withdrawal balance
        pendingWithdrawals[signer] += msg.value;

        return voucher.tokenId;
    }

    function royaltyInfo(uint256, uint256 value)
        external
        view
        override(IERC2981Royalties)
        returns (address receiver, uint256 royaltyAmount)
    {
        RoyaltyInfo memory _royalties = royalties;
        receiver = _royalties.recipient;
        royaltyAmount = (value * _royalties.amount) / 10000;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155, ERC2981Base, AccessControl) returns (bool) {
        return interfaceId == type(IUnicERC1155).interfaceId || super.supportsInterface(interfaceId);
    }

    /// @notice Transfers all pending withdrawal balance to the caller. Reverts if the caller is not an authorized minter.
    function withdraw() public onlyOwner {
        // IMPORTANT: casting msg.sender to a payable address is only safe if ALL members of the minter role are payable addresses.
        address payable receiver = payable(msg.sender);

        uint amount = pendingWithdrawals[receiver];
        // zero account before transfer to prevent re-entrancy attack
        pendingWithdrawals[receiver] = 0;
        receiver.transfer(amount);
    }

    /// @notice Returns a hash of the given NFTVoucher, prepared using EIP712 typed data hashing rules.
    /// @param voucher An NFTVoucher to hash.
    function _hash(NFTVoucher calldata voucher) internal view returns (bytes32) {
        return _hashTypedDataV4(keccak256(abi.encode(
            keccak256("NFTVoucher(uint256 tokenId,uint256 minPrice,uint256 amount)"),
            voucher.tokenId,
            voucher.minPrice,
            voucher.amount
        )));
    }

    // Value is in basis points so 10000 = 100% , 100 = 1% etc
    function _setRoyalties(address recipient, uint256 value) internal {
        if (value > 10000) revert RoyaltyTooHigh();
        royalties = RoyaltyInfo(recipient, uint24(value));
    }

    /// @notice Verifies the signature for a given NFTVoucher, returning the address of the signer.
    /// @dev Will revert if the signature is invalid. Does not verify that the signer is authorized to mint NFTs.
    /// @param voucher An NFTVoucher describing an unminted NFT.
    function _verify(NFTVoucher calldata voucher) internal view returns (address) {
        bytes32 digest = _hash(voucher);
        return ECDSA.recover(digest, voucher.signature);
    }
}