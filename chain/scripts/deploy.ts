import { ethers, upgrades } from "hardhat";

async function main() {
    // Erstellen Sie Contract Factories für Ihre Upgradeable Contracts
    const EventStorage = await ethers.getContractFactory("EventStorage");
    const TicketStorage = await ethers.getContractFactory("TicketStorage");
    const EventManagement = await ethers.getContractFactory("EventManagement");
    const TicketManagement = await ethers.getContractFactory("TicketManagement");

    // Deployen Sie die Storage Contracts als Upgradeable Contracts
    const eventStorage = await upgrades.deployProxy(EventStorage, [], { initializer: 'initialize' });
    const ticketStorage = await upgrades.deployProxy(TicketStorage, [], { initializer: 'initialize' });

    console.log("EventStorage deployed to:", eventStorage.address);
    console.log("TicketStorage deployed to:", ticketStorage.address);

    // Deployen Sie die Management Contracts als Upgradeable Contracts
    // Geben Sie die Adressen der Storage Contracts als Argumente an
    const eventManagement = await upgrades.deployProxy(EventManagement, [eventStorage.address, ticketStorage.address], { initializer: 'initialize' });
    const ticketManagement = await upgrades.deployProxy(TicketManagement, [eventStorage.address, ticketStorage.address], { initializer: 'initialize' });

    console.log("EventManagement deployed to:", eventManagement.address);
    console.log("TicketManagement deployed to:", ticketManagement.address);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
