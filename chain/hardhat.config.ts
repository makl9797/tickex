import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox-viem";

const POLYGON_MUMBAI_RPC_URL = "https://rpc-mumbai.maticvigil.com";

const config: HardhatUserConfig = {
  solidity: "0.8.19",
  networks: {
    hardhat: {
      chainId: 80001,
      forking: {
        url: POLYGON_MUMBAI_RPC_URL
      }
    }
  }
};

export default config;
