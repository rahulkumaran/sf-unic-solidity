import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { testnets } from "../utils/constants";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;

  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  const unicMapperDeploy = await deploy("UnicMapper", {
    from: deployer,
    log: true,
  });

  const unicFactoryDeploy = await deploy("UnicFactory", {
    from: deployer,
    log: true,
  });

  console.log("UnicMapper: ", unicMapperDeploy.address);
  console.log("UnicFactory: ", unicFactoryDeploy.address);
};

func.tags = ["local", "seed", "main"];
export default func;
