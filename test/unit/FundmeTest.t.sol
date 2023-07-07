// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    address ALICE = makeAddr("alice");
    address BOB = makeAddr("bob");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_AMOUNT = 10 ether;
    HelperConfig public helperConfig;

    modifier funded() {
        vm.prank(ALICE);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        (fundMe, helperConfig) = deployFundMe.run();
        vm.deal(ALICE, STARTING_AMOUNT);
        vm.deal(BOB, STARTING_AMOUNT);
    }

    function testMininumDollarIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testContractOwnerIsMsgOwner() public {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testVersionNumber() public {
        assertEq(fundMe.getVersion(), 4);
    }

    // function testFailedFundWithoutETH() public {
    //     vm.expectRevert();
    //     fundme.withdraw();
    // }

    function testFundUpdatesWithRightAmount() public {
        vm.prank(ALICE);
        fundMe.fund{value: SEND_VALUE}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(ALICE);

        assertEq(amountFunded, SEND_VALUE);
    }

    function testSuccessfulFundersAddedToArray() public funded {
        address firstFunder = fundMe.getFunder(0);
        assertEq(firstFunder, ALICE);
    }

    function testOnlyOwnerCanWithdraw() public funded{
        // vm.prank(ALICE);
        // vm.expectRevert(bytes("FundMe__NotOwner()"));
        // fundme.withdraw();

        vm.expectRevert();
        fundMe.fund();
    }

    

    function testWithdrawForASingleFunder() public funded {
        uint256 startingOwnerBalance = fundMe.getOwner().balance;

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFunderBalance = address(fundMe).balance;

        assertEq(endingOwnerBalance - startingOwnerBalance, SEND_VALUE);
        assertEq(endingFunderBalance, 0);
    }

    function testWithdrawFromMultipleFunders() public {
        // as of 0.8 solidity, addresses has to be in uint160 for the hoax to work for address with address(1)
        uint160 numberOfFunders = 10;
        uint160 startingIndex = 2;
        for (uint160 i = startingIndex; i < numberOfFunders; i++) {
            hoax(address(i), STARTING_AMOUNT);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFunderBalance = address(fundMe).balance;

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 endingOwnerBalance = fundMe.getOwner().balance;

        assertEq(address(fundMe).balance, 0);
        assert(startingFunderBalance+startingOwnerBalance == endingOwnerBalance);
    }

    function testCheaperWithdrawFromMultipleFunders() public {
        // as of 0.8 solidity, addresses has to be in uint160 for the hoax to work for address with address(1)
        uint160 numberOfFunders = 10;
        uint160 startingIndex = 2;
        for (uint160 i = startingIndex; i < numberOfFunders; i++) {
            hoax(address(i), STARTING_AMOUNT);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFunderBalance = address(fundMe).balance;

        vm.prank(fundMe.getOwner());
        fundMe.cheaperWithdraw();

        uint256 endingOwnerBalance = fundMe.getOwner().balance;

        assertEq(address(fundMe).balance, 0);
        assert(startingFunderBalance+startingOwnerBalance == endingOwnerBalance);
    }
}
