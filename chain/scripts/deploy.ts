import { ethers } from "hardhat";

async function main() {
    const EventStorage = await ethers.getContractFactory("EventStorage");
    const TicketStorage = await ethers.getContractFactory("TicketStorage");
    const EventManagement = await ethers.getContractFactory("EventManagement");
    const TicketManagement = await ethers.getContractFactory("TicketManagement");

    const eventStorage = await EventStorage.deploy();
    await eventStorage.waitForDeployment();

    const ticketStorage = await TicketStorage.deploy();
    await ticketStorage.waitForDeployment();

    console.log("EventStorage deployed to:", eventStorage.target);
    console.log("TicketStorage deployed to:", ticketStorage.target);


    const eventManagement = await EventManagement.deploy(eventStorage.target, ticketStorage.target);
    await eventManagement.waitForDeployment();

    const ticketManagement = await TicketManagement.deploy(eventStorage.target, ticketStorage.target);
    await ticketManagement.waitForDeployment();

    console.log("EventManagement deployed to:", eventManagement.target);
    console.log("TicketManagement deployed to:", ticketManagement.target);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
