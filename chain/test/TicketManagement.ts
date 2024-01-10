import { ethers } from "hardhat";
import { expect } from "chai";
import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";

describe("TicketManagement Contract", function () {
  async function deployTicketManagementFixture() {
    const [owner, user1] = await ethers.getSigners();

    const EventStorage = await ethers.getContractFactory("EventStorage");
    const eventStorage = await EventStorage.deploy();

    const TicketStorage = await ethers.getContractFactory("TicketStorage");
    const ticketStorage = await TicketStorage.deploy();

    const TicketManagement = await ethers.getContractFactory("TicketManagement");
    const ticketManagement = await TicketManagement.deploy(eventStorage.target, ticketStorage.target);

    const ticketPrice = ethers.parseEther("0.1");
    const ticketsAvailable = 100;
    await eventStorage.createEvent(ticketPrice, ticketsAvailable, owner.address);

    return { ticketManagement, eventStorage, ticketStorage, owner, user1 };
  }

  describe("Ticket Purchase", function () {
    it("should allow users to buy tickets for an event", async function () {
      const { ticketManagement, owner, user1 } = await loadFixture(deployTicketManagementFixture);
      const eventId = 0;
      const ticketPrice = ethers.parseEther("0.1");

      await expect(ticketManagement.connect(user1).buyTicket(eventId, { value: ticketPrice }))
        .to.changeEtherBalances([user1, owner], [-ticketPrice, ticketPrice]); 
    });

    it("should not allow ticket purchases if no tickets are available", async function () {
      const { ticketManagement, eventStorage, owner, user1 } = await loadFixture(deployTicketManagementFixture);
      const eventId = 1;
      const ticketPrice = ethers.parseEther("0.1");

      await eventStorage.createEvent(ticketPrice, 0, owner.address);

      await expect(ticketManagement.connect(user1).buyTicket(eventId, { value: ticketPrice }))
        .to.be.revertedWith("No tickets available.");
    });

    it("should not allow ticket purchases with incorrect payment", async function () {
      const { ticketManagement, owner, user1 } = await loadFixture(deployTicketManagementFixture);
      const eventId = 0;
      const incorrectTicketPrice = ethers.parseEther("0.05");

      await expect(ticketManagement.connect(user1).buyTicket(eventId, { value: incorrectTicketPrice }))
        .to.be.revertedWith("Incorrect ticket price.");
    });
  });

  
});
