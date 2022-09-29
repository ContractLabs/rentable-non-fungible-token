// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "oz-custom/contracts/oz-upgradeable/token/ERC721/extensions/ERC721RentableUpgradeable.sol";

import "./interfaces/IRentableCollectible.sol";

import "./Collectible721.sol";

contract RentableCollectible721Upgradeable is
    IRentableCollectible,
    ERC721RentableUpgradeable,
    Collectible721Upgradeable
{
    using SafeCastUpgradeable for uint256;

    ///@dev value is equal to keccak256("Permit(address user,uint256 expires,uint256 deadline,uint256 nonce)")
    bytes32 private constant _PERMIT_TYPE_HASH =
        0xe1083cc5c80f93a4536f92f8603e7fd41b968f0442697679170436f978397d2f;

    function init(
        string calldata name_,
        string calldata symbol_,
        string calldata baseURI_,
        uint256 feeAmt_,
        IERC20Upgradeable feeToken_,
        IGovernanceV2 governance_,
        ITreasuryV2 treasury_
    ) external initializer {
        __Collectible_init(
            name_,
            symbol_,
            baseURI_,
            feeAmt_,
            feeToken_,
            governance_,
            treasury_,
            /////@dev value is equal to keccak256("RentableCollectible_v1")
            0xb2968efe7e8797044f984fc229747059269f7279ae7d4bb4737458dbb15e0f41
        );
    }

    function setUser(
        uint256 tokenId,
        uint64 expires_,
        uint256 deadline_,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external override whenNotPaused {
        if (block.timestamp > deadline_) revert RentableCollectible__Expired();

        UserInfo memory userInfo = _users[tokenId];
        if (userInfo.expires < block.timestamp && userInfo.user != address(0))
            revert RentableCollectible__Rented();
        address sender = _msgSender();
        _verify(
            sender,
            ownerOf(tokenId),
            keccak256(
                abi.encode(
                    _PERMIT_TYPE_HASH,
                    sender,
                    expires_,
                    deadline_,
                    _useNonce(tokenId)
                )
            ),
            v,
            r,
            s
        );

        userInfo.user = sender;
        unchecked {
            userInfo.expires = (block.timestamp + expires_).toUint96();
        }

        _users[tokenId] = userInfo;

        emit UserUpdated(tokenId, sender, expires_);
    }

    function setUser(
        uint256 tokenId_,
        address user_,
        uint64 expires_
    ) public override {
        _requireNotPaused();
        if (!_isApprovedOrOwner(_msgSender(), tokenId_))
            revert Rentable__OnlyOwnerOrApproved();

        UserInfo memory info = _users[tokenId_];
        info.user = user_;
        unchecked {
            info.expires = (block.timestamp + expires_).toUint96();
        }

        _users[tokenId_] = info;

        emit UserUpdated(tokenId_, user_, expires_);
    }

    function supportsInterface(bytes4 interfaceId_)
        public
        view
        override(Collectible721Upgradeable, ERC721RentableUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId_);
    }

    function _burn(uint256 tokenId_) internal override {
        super._burn(tokenId_);
    }

    function _beforeTokenTransfer(
        address from_,
        address to_,
        uint256 tokenId_
    ) internal override(Collectible721Upgradeable, ERC721RentableUpgradeable) {
        super._beforeTokenTransfer(from_, to_, tokenId_);
    }
}