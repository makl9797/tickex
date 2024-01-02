import { ethers } from "hardhat";
import { expect } from "chai";
import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";

describe("TicketStorage Contract", function () {
  async function deployTicketStorageFixture() {
    const [owner, user1] = await ethers.getSigners();

    const TicketStorage = await ethers.getContractFactory("TicketStorage");
    const ticketStorage = await TicketStorage.deploy();

    return { ticketStorage, owner, user1 };
  }

  describe("Ticket Creation", function () {
    it("should allow creating a ticket", async function () {
      const { ticketStorage, owner } = await loadFixture(deployTicketStorageFixture);

      await expect(ticketStorage.createTicket(0, owner.address))
        .to.emit(ticketStorage, "TicketCreated")
        .withArgs(0, owner.address);
    });
  });

  describe("Ticket Redemption", function () {
    it("should allow redeeming a ticket", async function () {
      const { ticketStorage, owner } = await loadFixture(deployTicketStorageFixture);

      await ticketStorage.createTicket(0, owner.address);
      await expect(ticketStorage.redeemTicket(0))
        .to.emit(ticketStorage, "TicketRedeemed")
        .withArgs(0);
    });

    it("should not allow redeeming a ticket that does not exist", async function () {
      const { ticketStorage } = await loadFixture(deployTicketStorageFixture);

      await expect(ticketStorage.redeemTicket(999))
        .to.be.revertedWith("Ticket does not exist.");
    });

    it("should not allow redeeming a ticket that has already been redeemed", async function () {
      const { ticketStorage, owner } = await loadFixture(deployTicketStorageFixture);

      await ticketStorage.createTicket(0, owner.address);
      await ticketStorage.redeemTicket(0);
      await expect(ticketStorage.redeemTicket(0))
        .to.be.revertedWith("Ticket already redeemed.");
    });
  });

  describe("Get Ticket", function () {
    it("should return the correct ticket details", async function () {
      const { ticketStorage, owner } = await loadFixture(deployTicketStorageFixture);

      await ticketStorage.createTicket(0, owner.address);
      const ticket = await ticketStorage.getTicket(0);

      expect(ticket.eventId).to.equal(0);
      expect(ticket.owner).to.equal(owner.address);
      expect(ticket.isRedeemed).to.be.false;
    });

    it("should revert if the ticket does not exist", async function () {
      const { ticketStorage } = await loadFixture(deployTicketStorageFixture);

      await expect(ticketStorage.getTicket(999))
        .to.be.revertedWith("Ticket does not exist.");
    });
  });

  // Weitere Tests können hier hinzugefügt werden...
});
