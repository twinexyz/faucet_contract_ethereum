// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {Faucet} from "src/Faucet.sol";

contract ERC20Mock {
    string public name;
    string public symbol;
    uint8 public immutable decimals = 18;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    event Transfer(address indexed from, address indexed to, uint256);
    event Approval(address, address, uint256);
    constructor(string memory n, string memory s) {
        name = n;
        symbol = s;
    }
    function mint(address to, uint256 amt) external {
        balanceOf[to] += amt;
        totalSupply += amt;
        emit Transfer(address(0), to, amt);
    }
    function approve(address s, uint256 a) external returns (bool) {
        allowance[msg.sender][s] = a;
        emit Approval(msg.sender, s, a);
        return true;
    }
    function transfer(address to, uint256 a) external returns (bool) {
        _transfer(msg.sender, to, a);
        return true;
    }
    function transferFrom(
        address f,
        address t,
        uint256 a
    ) external returns (bool) {
        uint256 al = allowance[f][msg.sender];
        require(al >= a, "allow");
        allowance[f][msg.sender] = al - a;
        _transfer(f, t, a);
        return true;
    }
    function _transfer(address f, address t, uint256 a) internal {
        require(balanceOf[f] >= a, "bal");
        balanceOf[f] -= a;
        balanceOf[t] += a;
        emit Transfer(f, t, a);
    }
}

contract FaucetTest is Test {
    Faucet faucet;
    ERC20Mock tok;
    address owner = address(0xABCD);
    address alice = address(0xA11CE);

    function setUp() public {
        vm.startPrank(owner);
        faucet = new Faucet(owner);
        vm.stopPrank();

        tok = new ERC20Mock("TestToken", "TT");
        tok.mint(owner, 1_000_000 ether);

        // fund faucet with ERC20
        vm.prank(owner);
        tok.transfer(address(faucet), 500_000 ether);

        // configure token: drop=50, cooldown=1 day
        vm.prank(owner);
        faucet.setTokenConfig(address(tok), true, 50 ether, 1 days);
    }

    function testClaimFixedAmount() public {
        vm.prank(alice);
        faucet.claim(address(tok), alice);
        assertEq(tok.balanceOf(alice), 50 ether);
    }

    function testCooldown() public {
        vm.prank(alice);
        faucet.claim(address(tok), alice);
        vm.prank(alice);
        vm.expectRevert();
        faucet.claim(address(tok), alice); // within cooldown
        vm.warp(block.timestamp + 1 days + 1);
        vm.prank(alice);
        faucet.claim(address(tok), alice);
        assertEq(tok.balanceOf(alice), 100 ether);
    }

    function testPause() public {
        vm.prank(owner);
        faucet.pause();
        vm.prank(alice);
        vm.expectRevert();
        faucet.claim(address(tok), alice);
        vm.prank(owner);
        faucet.unpause();
        vm.prank(alice);
        faucet.claim(address(tok), alice);
    }

    function testInsufficientBalance() public {
        // withdraw most tokens to owner to simulate empty faucet
        vm.prank(owner);
        faucet.withdraw(address(tok), owner, 500_000 ether);
        vm.prank(alice);
        vm.expectRevert();
        faucet.claim(address(tok), alice);
    }

    function testDisableToken() public {
        vm.prank(owner);
        faucet.setTokenConfig(address(tok), false, 50 ether, 1 days);
        vm.prank(alice);
        vm.expectRevert();
        faucet.claim(address(tok), alice);
    }

    function testRejectZeroTokenConfig() public {
        // only if you added the require(token != address(0))
        vm.prank(owner);
        vm.expectRevert(bytes("TOKEN_ZERO_ADDR"));
        faucet.setTokenConfig(address(0), true, 1 ether, 1 days);
    }
}
