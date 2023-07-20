// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {DeployOurToken} from "../script/DeployOurToken.s.sol";
import {OurToken} from "../src/OurToken.sol";
import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

interface MintableToken {
    function mint(address, uint256) external;
}

contract OurTokenTest is StdCheats, Test {
    uint256 BOB_STARTING_AMOUNT = 100 ether;

    OurToken public ourToken;
    DeployOurToken public deployer;
    address public deployerAddress;
    address bob;
    address alice;

    function setUp() public {
        deployer = new DeployOurToken();
        ourToken = deployer.run();

        bob = makeAddr("bob");
        alice = makeAddr("alice");

        deployerAddress = vm.addr(deployer.deployerKey());
        vm.prank(deployerAddress);
        ourToken.transfer(bob, BOB_STARTING_AMOUNT);
    }

    function testAllowancesOrig() public {
        uint256 initialAllowance = 1000;

        // Alice approves Bob to spend tokens on her behalf
        vm.prank(bob);
        ourToken.approve(alice, initialAllowance);
        uint256 transferAmount = 500;

        vm.prank(alice);
        ourToken.transferFrom(bob, alice, transferAmount);
        assertEq(ourToken.balanceOf(alice), transferAmount);
        assertEq(ourToken.balanceOf(bob), BOB_STARTING_AMOUNT - transferAmount);
    }

    // can you get the coverage up?
    // Test for initial token supply
    function testInitialSupply() public {
        assertEq(ourToken.totalSupply(), deployer.INITIAL_SUPPLY());
    }

    // Test that users can't mint new tokens
    function testUsersCantMint() public {
        vm.expectRevert();
        MintableToken(address(ourToken)).mint(address(this), 1);
    }

    // Test for correct decimals
    function testDecimals() public {
        assertEq(ourToken.decimals(), deployer.DECIMALS());
    }

    // Test token transfers
    function testTransfers() public {
        uint256 amount = 1000;
        address receiver = address(0x1);
        uint256 initialBalanceSender = ourToken.balanceOf(bob);
        uint256 initialBalanceRecipient = ourToken.balanceOf(receiver);
        vm.prank(bob);
        ourToken.transfer(receiver, amount);
        assertEq(ourToken.balanceOf(bob), initialBalanceSender - amount);
        assertEq(ourToken.balanceOf(receiver), initialBalanceRecipient + amount);
    }

    // Test token allowances
    function testAllowances() public {
        address spender = address(0x123); // Replace with the actual address you want to test
        uint256 amount = 100;

        ourToken.approve(spender, amount);
        assertEq(ourToken.allowance(address(this), spender), amount);

        uint256 newAmount = 50;
        ourToken.increaseAllowance(spender, newAmount);
        assertEq(ourToken.allowance(address(this), spender), amount + newAmount);

        ourToken.decreaseAllowance(spender, newAmount);
        assertEq(ourToken.allowance(address(this), spender), amount);
    }
}
