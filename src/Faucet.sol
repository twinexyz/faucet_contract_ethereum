// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/access/Ownable.sol";      // Import Ownable to call its constructor
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Faucet is Ownable2Step, Pausable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // ===== Errors =====
    error TokenDisabled();
    error CooldownActive(uint256 secondsRemaining);
    error InsufficientFaucetBalance();

    // ===== Events =====
    event Claimed(
        address indexed user,
        address indexed token,
        address indexed to,
        uint256 amount,
        uint64 timestamp
    );
    event TokenConfigured(
        address indexed token,
        bool enabled,
        uint128 dropAmount,
        uint32 cooldownSeconds
    );
    event Withdrawn(address indexed token, address indexed to, uint256 amount);

    struct TokenConfig {
        bool    enabled;
        uint128 dropAmount;
        uint32  cooldownSeconds;
    }

    // Mapping from token address to its configuration
    mapping(address token => TokenConfig) public tokenConfigs;
    // Last claim timestamp per token per user
    mapping(address token => mapping(address user => uint64)) public lastClaimAt;

    constructor(address initialOwner) 
        Ownable(initialOwner == address(0) ? msg.sender : initialOwner) 
    {
        // If initialOwner is zero, default to deployer. Owner is set via Ownable constructor.
    }

    // ===== Admin Functions =====

    /**
     * @notice Configure a token for the faucet (enable/disable, set drop amount and cooldown).
     * @param token The ERC20 token address to configure.
     * @param enabled True to enable claiming this token, false to disable.
     * @param dropAmount The amount of tokens to dispense per claim.
     * @param cooldownSeconds How many seconds a user must wait between claims for this token.
     */
    function setTokenConfig(
        address token,
        bool enabled,
        uint256 dropAmount,
        uint256 cooldownSeconds
    ) external onlyOwner {
        require(token != address(0), "TOKEN_ZERO_ADDR");
        tokenConfigs[token] = TokenConfig({
            enabled: enabled,
            dropAmount: uint128(dropAmount),
            cooldownSeconds: uint32(cooldownSeconds)
        });
        emit TokenConfigured(token, enabled, uint128(dropAmount), uint32(cooldownSeconds));
    }

    /// @notice Pause the faucet (disables claiming) – onlyOwner.
    function pause() external onlyOwner {
        _pause();
    }

    /// @notice Unpause the faucet (re-enables claiming) – onlyOwner.
    function unpause() external onlyOwner {
        _unpause();
    }

    /**
     * @notice Withdraw tokens from the faucet back to the owner (or another address).
     * @param token The ERC20 token address to withdraw.
     * @param to Destination address for the tokens (if zero, defaults to the owner).
     * @param amount Amount of tokens to withdraw.
     */
    function withdraw(address token, address to, uint256 amount) 
        external 
        onlyOwner 
        nonReentrant 
    {
        if (to == address(0)) {
            to = owner();  // default to contract owner
        }
        IERC20(token).safeTransfer(to, amount);
        emit Withdrawn(token, to, amount);
    }

    // ===== View Functions =====

    /// @notice Get the configuration for a token.
    function getTokenConfig(address token) external view returns (TokenConfig memory) {
        return tokenConfigs[token];
    }

    /// @notice Get the next allowed claim time for a user on a given token.
    function nextClaimTime(address token, address user) public view returns (uint64) {
        TokenConfig memory cfg = tokenConfigs[token];
        uint64 last = lastClaimAt[token][user];
        if (last == 0 || cfg.cooldownSeconds == 0) {
            return 0; // no cooldown needed if never claimed or cooldown is zero
        }
        unchecked {
            return last + uint64(cfg.cooldownSeconds);
        }
    }

    /// @notice Returns how many seconds until a user can next claim a token. Returns 0 if claimable now.
    function secondsUntilNextClaim(address token, address user) external view returns (uint256) {
        uint64 nxt = nextClaimTime(token, user);
        if (nxt == 0) {
            return 0;
        }
        // If current time is past the next claim time, return 0, otherwise return the difference
        return block.timestamp >= nxt ? 0 : nxt - uint64(block.timestamp);
    }

    // ===== User Function: Claim Tokens =====

    /**
     * @notice Claim the faucet drop for a given token. Can specify a recipient address.
     * @param token The ERC20 token to claim.
     * @param to Address to send the tokens to (if zero, sends to the caller).
     *
     * Requirements:
     * - Faucet must be unpaused.
     * - Token must be configured and enabled.
     * - Caller must wait for cooldown period since their last claim for this token.
     * - Faucet contract must have enough balance of the token.
     */
    function claim(address token, address to) external whenNotPaused nonReentrant {
        // Default to sending tokens to the caller if no recipient specified
        if (to == address(0)) {
            to = msg.sender;
        }

        TokenConfig memory cfg = tokenConfigs[token];
        if (!cfg.enabled) {
            revert TokenDisabled();
        }

        // Enforce cooldown: revert if current time is before the allowed next claim time
        uint64 nextTime = nextClaimTime(token, msg.sender);
        if (nextTime != 0 && block.timestamp < nextTime) {
            // Calculate remaining seconds and revert with CooldownActive error
            uint256 remaining = nextTime - uint64(block.timestamp);
            revert CooldownActive(remaining);
        }

        uint256 amount = cfg.dropAmount;
        if (amount == 0) {
            // Treat zero drop amount as disabled (no tokens to dispense)
            revert TokenDisabled();
        }

        // Check faucet balance for the token
        if (IERC20(token).balanceOf(address(this)) < amount) {
            revert InsufficientFaucetBalance();
        }

        // Transfer tokens to the recipient
        IERC20(token).safeTransfer(to, amount);

        // Record the claim time for cooldown tracking
        lastClaimAt[token][msg.sender] = uint64(block.timestamp);

        emit Claimed(msg.sender, token, to, amount, uint64(block.timestamp));
    }
}
