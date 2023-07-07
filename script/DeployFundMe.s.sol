// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {console} from 'forge-std/Test.sol';
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";


contract DeployFundMe is Script {
    function run() external returns(FundMe, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        address ethUSDPriceFeed = helperConfig.activeNetworkConfig();
        console.log('ethUSDPriceFeed', ethUSDPriceFeed);

        vm.startBroadcast();
        FundMe fundme = new FundMe(ethUSDPriceFeed);
        vm.stopBroadcast();
        return (fundme, helperConfig);
    }
}