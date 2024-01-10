import { ethers } from "hardhat";
import { expect } from "chai";
import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";

describe("TicketStorage Contract", function () {
  async function deployTicketStorageFixture() {
    const [owner, user1] = await ethers.getSigners();

    const EventStorage = await ethers.getContractFactory("EventStorage");
    const eventStorage = await EventStorage.deploy();

    const TicketStorage = await ethers.getContractFactory("TicketStorage");
    const ticketStorage = await TicketStorage.deploy();

    // Erstelle ein Event, bevor Tickets erstellt werden
    const ticketPrice = ethers.parseEther("0.1");
    const ticketsAvailable = 100;
    await eventStorage.createEvent(ticketPrice, ticketsAvailable, owner.address);

    return { eventStorage, ticketStorage, owner, user1 };
  }

  describe("Ticket Creation", function () {
    it("should allow creating a ticket", async function () {
      const { ticketStorage, owner } = await loadFixture(deployTicketStorageFixture);
      const eventId = 0;
      const ticketNumber = 0;
      const price = ethers.parseEther("0.1");

      await expect(ticketStorage.createTicket(eventId, ticketNumber, price, owner.address))
        .to.emit(ticketStorage, "TicketCreated")
        .withArgs(ticketNumber, eventId, price, owner.address, false);
    });
  });

  describe("Ticket Redemption", function () {
    it("should allow redeeming a ticket", async function () {
      const { ticketStorage, owner } = await loadFixture(deployTicketStorageFixture);
      const eventId = 0;
      const ticketNumber = 0;
      const price = ethers.parseEther("0.1");

      await ticketStorage.createTicket(eventId, ticketNumber, price, owner.address);
      await expect(ticketStorage.redeemTicket(eventId, ticketNumber))
        .to.emit(ticketStorage, "TicketRedeemed")
        .withArgs(ticketNumber, eventId, owner.address, true);
    });

    it("should not allow redeeming a ticket that does not exist", async function () {
      const { ticketStorage } = await loadFixture(deployTicketStorageFixture);
      const eventId = 0;
      const invalidTicketNumber = 999;

      await expect(ticketStorage.redeemTicket(eventId, invalidTicketNumber))
        .to.be.revertedWith("Ticket does not exist.");
    });

    it("should not allow redeeming a ticket that has already been redeemed", async function () {
      const { ticketStorage, owner } = await loadFixture(deployTicketStorageFixture);
      const eventId = 0;
      const ticketNumber = 0;
      const price = ethers.parseEther("0.1");

      await ticketStorage.createTicket(eventId, ticketNumber, price, owner.address);
      await ticketStorage.redeemTicket(eventId, ticketNumber);
      await expect(ticketStorage.redeemTicket(eventId, ticketNumber))
        .to.be.revertedWith("Ticket already redeemed.");
    });
  });

  describe("Get Ticket", function () {
    it("should return the correct ticket details", async function () {
      const { ticketStorage, owner } = await loadFixture(deployTicketStorageFixture);
      const eventId = 0;
      const ticketNumber = 0;
      const price = ethers.parseEther("0.1");

      await ticketStorage.createTicket(eventId, ticketNumber, price, owner.address);
      const ticket = await ticketStorage.getTicket(eventId, ticketNumber);

      expect(ticket.ticketNumber).to.equal(ticketNumber);
      expect(ticket.eventId).to.equal(eventId);
      expect(ticket.price).to.equal(price);
      expect(ticket.owner).to.equal(owner.address);
      expect(ticket.isRedeemed).to.be.false;
    });

    it("should revert if the ticket does not exist", async function () {
      const { ticketStorage } = await loadFixture(deployTicketStorageFixture);
      const eventId = 0;
      const invalidTicketNumber = 999;

      await expect(ticketStorage.getTicket(eventId, invalidTicketNumber))
        .to.be.revertedWith("Ticket does not exist.");
    });
  });

  
});
