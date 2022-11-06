// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

interface IUnicERC1155 {
    /// @notice Represents an un-minted NFT, which has not yet been recorded into the blockchain. A signed voucher can be redeemed for a real NFT using the redeem function.
    struct NFTVoucher {
        /// @notice The id of the token to be redeemed. Must be unique - if another token with this ID already exists, the redeem function will revert.
        uint256 tokenId;

        /// @notice The minimum price (in wei) that the NFT creator is willing to accept for the initial sale of this NFT.
        uint256 minPrice;

        /// @notice Amount of token minted
        uint256 amount;

        /// @notice the EIP-712 signature of all other fields in the NFTVoucher struct. For a voucher to be valid, it must be signed by an account with the MINTER_ROLE.
        bytes signature;
    }

    function availableToWithdraw() external view returns (uint256);

    function burn( address from, uint256 id, uint256 amount) external;

    function mint( address to, uint256 id, uint256 amount) external;

    function redeem(address redeemer, NFTVoucher calldata voucher) external payable returns (uint256);

    function withdraw() external;

    error NotOwner();

    error InvalidSignature();

    error InsufficientFunds();

    error RoyaltyTooHigh();
}