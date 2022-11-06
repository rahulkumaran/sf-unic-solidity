// https://github.com/wighawag/hardhat-deploy#2-extra-hardhatconfig-networks-options
import "dotenv/config";
import { HardhatUserConfig } from "hardhat/types";
import "hardhat-deploy";
import "@nomiclabs/hardhat-ethers";
import "@typechain/hardhat";
import "solidity-coverage";
import "@nomiclabs/hardhat-etherscan";
import "hardhat-interface-generator";
import "hardhat-contract-sizer";

const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: "0.8.13",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  },
  networks: {
    hardhat: {
      chainId: +process.env.MAINNET_LOCAL_CHAINID!,
      saveDeployments: false,
      forking: {
        url: "https://eth-mainnet.alchemyapi.io/v2/7p4KzWgfAW2gU_4xOoPT5mpxDdOgFycO",
      },
    },
    rinkeby: {
      url: process.env.RINKEBY_URI,
      chainId: +process.env.RINKEBY_CHAINID!,
      accounts: [`${process.env.RINKEBY_PRIVATE_KEY}`],
      timeout: 600000,
      gasPrice: 200000000000,
      gas: 800000000,
      saveDeployments: false,
    },
    mainnet: {
      url: process.env.MAINNET_URI,
      chainId: +process.env.MAINNET_CHAINID!,
      accounts: [`${process.env.MAINNET_PRIVATE_KEY}`],
      timeout: 600000,
      gasPrice: 200000000000,
      gas: 800000000,
      saveDeployments: true,
    },
    evmos: {
      url: process.env.EVMOS_URI,
      chainId: +process.env.EVMOS_CHAINID!,
      accounts: [`${process.env.EVMOS_PRIVATE_KEY}`],
      timeout: 600000,
      gasPrice: 200000000000,
      gas: 800000000,
      saveDeployments: true,
    },
    optimism: {
      url: process.env.OPTIMISM_URI,
      chainId: +process.env.OPTIMISM_CHAINID!,
      accounts: [`${process.env.OPTIMISM_PRIVATE_KEY}`],
      timeout: 600000,
      gasPrice: 200000000000,
      gas: 800000000,
      saveDeployments: true,
    },
    polygon: {
      url: process.env.POLYGON_URI,
      chainId: +process.env.POLYGON_CHAINID!,
      accounts: [`${process.env.POLYGON_PRIVATE_KEY}`],
      timeout: 600000,
      gasPrice: 200000000000,
      gas: 800000000,
      saveDeployments: true,
    },
  },
  paths: {
    sources: "./src/contracts",
    artifacts: "./build/artifacts",
    cache: "./build/cache",
  },
  namedAccounts: {
    deployer: 0,
  },
};

export default config;
