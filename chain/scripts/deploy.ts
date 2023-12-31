import { ethers } from "hardhat";

async function main() {
  const Tickex = await ethers.getContractFactory("Tickex");
  const tickex = await Tickex.deploy();
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

