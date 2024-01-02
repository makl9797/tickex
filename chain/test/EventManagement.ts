import { ethers } from "hardhat";
import { expect } from "chai";
import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";

describe("EventManagement Contract", function () {
  async function deployEventManagementFixture() {
    const [owner, user1, user2] = await ethers.getSigners();

    const EventStorage = await ethers.getContractFactory("EventStorage");
    const eventStorage = await EventStorage.deploy();

    const TicketStorage = await ethers.getContractFactory("TicketStorage");
    const ticketStorage = await TicketStorage.deploy();

    const EventManagement = await ethers.getContractFactory("EventManagement");
    const eventManagement = await EventManagement.deploy(eventStorage.target, ticketStorage.target);

    return { eventManagement, eventStorage, ticketStorage, owner, user1, user2 };
  }

  describe("Event Creation", function () {
    it("should allow the owner to create an event", async function () {
      const { eventManagement, eventStorage, owner } = await loadFixture(deployEventManagementFixture);
      const ticketPrice = ethers.parseEther("0.1");
      const ticketsAvailable = 1000;

      await expect(eventManagement.createEvent(ticketPrice, ticketsAvailable))
        .to.emit(eventStorage, "EventCreated")
        .withArgs(0, ticketPrice, ticketsAvailable, owner.address);
    });
  });

  describe("Event Update", function () {
    it("should allow the owner to update an event", async function () {
      const { eventManagement, eventStorage, owner } = await loadFixture(deployEventManagementFixture);
      const ticketPrice = ethers.parseEther("0.1");
      const ticketsAvailable = 1000;
      await eventManagement.createEvent(ticketPrice, ticketsAvailable);
      const newTicketPrice = ethers.parseEther("0.2");
      const newTicketsAvailable = 900;

      await expect(eventManagement.updateEvent(0, newTicketPrice, newTicketsAvailable))
        .to.emit(eventStorage, "EventUpdated")
        .withArgs(0, newTicketPrice, newTicketsAvailable, owner.address);
    });

    it("should not allow a non-owner to update an event", async function () {
      const { eventManagement, owner, user1 } = await loadFixture(deployEventManagementFixture);
      const ticketPrice = ethers.parseEther("0.1");
      const ticketsAvailable = 1000;
      await eventManagement.createEvent(ticketPrice, ticketsAvailable);
      await expect(eventManagement.connect(user1).updateEvent(0, ticketPrice, ticketsAvailable))
        .to.be.revertedWith("Access denied: Not the event owner.");
    });
  });

  describe("Ticket Redemption", function () {
    it("should allow ticket redemption by the event owner", async function () {
      const { eventManagement, ticketStorage, owner, user1 } = await loadFixture(deployEventManagementFixture);

      await eventManagement.createEvent(ethers.parseEther("0.1"), 1000);
      await ticketStorage.createTicket(0, 0, ethers.parseEther("0.1"), user1.address);

      await expect(eventManagement.redeemTicket(0, 0))
        .to.emit(ticketStorage, "TicketRedeemed")
        .withArgs(0, 0, user1.address, true);
    });

    it("should not allow ticket redemption by a non-owner", async function () {
      const { eventManagement, ticketStorage, user1, user2 } = await loadFixture(deployEventManagementFixture);
      await eventManagement.createEvent(ethers.parseEther("0.1"), 1000);
      await ticketStorage.createTicket(0, 0, ethers.parseEther("0.1"), user2.address);
      await expect(eventManagement.connect(user1).redeemTicket(0, 0))
        .to.be.revertedWith("Access denied: Not the event owner.");
    });
  });


});
