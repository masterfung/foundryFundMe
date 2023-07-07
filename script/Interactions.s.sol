// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundingFundMe is Script {
    uint256 public constant SEND_VALUE = 0.01 ether;

    function toFund(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentDeployedContract = DevOpsTools
            .get_most_recent_deployment("FundMe", block.chainid);

        vm.startBroadcast();
        toFund(mostRecentDeployedContract);
        vm.stopBroadcast();
    }
}

contract WithdrawingFundMe is Script {
    function toWithdraw(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).cheaperWithdraw();
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentDeployedContract = DevOpsTools
            .get_most_recent_deployment("FundMe", block.chainid);

        vm.startBroadcast();
        toWithdraw(mostRecentDeployedContract);
        vm.stopBroadcast();
    }
}
