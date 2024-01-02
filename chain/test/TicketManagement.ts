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

    return { ticketManagement, eventStorage, ticketStorage, owner, user1 };
  }

  describe("Ticket Purchase", function () {
    it("should allow users to buy tickets for an event", async function () {
      const { ticketManagement, eventStorage, owner, user1 } = await loadFixture(deployTicketManagementFixture);

      // Erstelle ein Event
      await eventStorage.connect(owner).createEvent(100, 1000);

      // Kaufe ein Ticket
      await expect(ticketManagement.connect(user1).buyTicket(0, { value: 100 }))
        .to.emit(ticketManagement, "TicketPurchased")
        .withArgs(0, user1.address);
    });

    it("should not allow ticket purchases if the event is sold out", async function () {
      const { ticketManagement, eventStorage, owner, user1 } = await loadFixture(deployTicketManagementFixture);

      // Erstelle ein Event mit 0 Tickets
      await eventStorage.connect(owner).createEvent(100, 0);

      // Versuche, ein Ticket zu kaufen
      await expect(ticketManagement.connect(user1).buyTicket(0, { value: 100 }))
        .to.be.revertedWith("No tickets available.");
    });

    it("should not allow ticket purchases with incorrect payment", async function () {
      const { ticketManagement, eventStorage, owner, user1 } = await loadFixture(deployTicketManagementFixture);

      // Erstelle ein Event
      await eventStorage.connect(owner).createEvent(100, 1000);

      // Versuche, ein Ticket mit falschem Betrag zu kaufen
      await expect(ticketManagement.connect(user1).buyTicket(0, { value: 50 }))
        .to.be.revertedWith("Incorrect ticket price.");
    });
  });

  // Weitere Tests können hier hinzugefügt werden...
});
