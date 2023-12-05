import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import { configDotenv } from "dotenv";
require("dotenv").config();

const config: HardhatUserConfig = {
  solidity: "0.8.19",
};

export default config;
