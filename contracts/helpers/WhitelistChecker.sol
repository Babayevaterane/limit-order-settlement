// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

import "../interfaces/IWhitelistRegistry.sol";

/// @title Contract with modifier for check does address in whitelist
contract WhitelistChecker {
    error AccessDenied();

    uint256 private constant _NOT_CHECKED = 1;
    uint256 private constant _CHECKED = 2;

    IWhitelistRegistry private immutable _whitelist;
    address private _limitOrderProtocol;
    uint256 private _checked = _NOT_CHECKED;

    constructor(IWhitelistRegistry whitelist, address limitOrderProtocol) {
        _whitelist = whitelist;
        _limitOrderProtocol = limitOrderProtocol;
    }

    modifier onlyWhitelistedEOA() {
        _enforceWhitelist(tx.origin);  // solhint-disable-line avoid-tx-origin
        _;
    }

    modifier onlyWhitelisted(address account) {
        _enforceWhitelist(account);
        if (_checked == _NOT_CHECKED) {
            _checked = _CHECKED;
            _;
            _checked = _NOT_CHECKED;
        } else {
            _;
        }
    }

    modifier onlyLimitOrderProtocol() {
        if (msg.sender != _limitOrderProtocol) revert AccessDenied();
        if (_checked == _NOT_CHECKED && !_isWhitelisted(tx.origin)) revert AccessDenied();  // solhint-disable-line avoid-tx-origin
        _;
    }

    function _enforceWhitelist(address account) private view {
        if (!_isWhitelisted(account)) revert AccessDenied();
    }

    function _isWhitelisted(address account) private view returns(bool) {
        return _whitelist.status(account) == uint256(IWhitelistRegistry.Status.Verified);
    }
}