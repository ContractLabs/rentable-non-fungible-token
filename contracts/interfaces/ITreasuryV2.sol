// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "oz-custom/contracts/oz-upgradeable/token/ERC20/IERC20Upgradeable.sol";

interface ITreasuryV2 {
    error Treasury__Expired();
    error Treasury__LengthMismatch();

    event PaymentsUpdated();
    event PricesUpdated();
    event PriceUpdated(
        IERC20Upgradeable indexed token,
        uint256 indexed from,
        uint256 indexed to
    );
    event PaymentRemoved(address indexed token);
    event PaymentsRemoved();

    function supportedPayment(IERC20Upgradeable token_)
        external
        view
        returns (bool);
}