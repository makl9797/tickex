import { ethers } from "hardhat";
import { expect } from "chai";
import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";

describe("EventManagement Contract", function () {
  async function deployEventManagementFixture() {
    const [deployer, user1, user2] = await ethers.getSigners();

    const EventStorage = await ethers.getContractFactory("EventStorage");
    const eventStorage = await EventStorage.deploy();

    const TicketStorage = await ethers.getContractFactory("TicketStorage");
    const ticketStorage = await TicketStorage.deploy();

    const EventManagement = await ethers.getContractFactory("EventManagement");
    const eventManagement = await EventManagement.deploy(eventStorage.target, ticketStorage.target);

    return { eventManagement, eventStorage, ticketStorage, deployer, user1, user2 };
  }

  describe("Event Creation", function () {
    it("should allow a user to create an event", async function () {
      const { eventManagement, eventStorage, deployer } = await loadFixture(deployEventManagementFixture);
      const ticketPrice = ethers.parseEther("0.1");
      const ticketsAvailable = 1000;

      await expect(eventManagement.connect(deployer).createEvent(ticketPrice, ticketsAvailable))
        .to.emit(eventStorage, "EventCreated")
        .withArgs(0, ticketPrice, ticketsAvailable, deployer.address);
    });
  });

  describe("Event Update", function () {
    it("should allow the event creator to update the event", async function () {
      const { eventManagement, eventStorage, deployer } = await loadFixture(deployEventManagementFixture);
      const ticketPrice = ethers.parseEther("0.1");
      const ticketsAvailable = 1000;
      await eventManagement.connect(deployer).createEvent(ticketPrice, ticketsAvailable);
      const newTicketPrice = ethers.parseEther("0.2");
      const newTicketsAvailable = 900;

      await expect(eventManagement.connect(deployer).updateEvent(0, newTicketPrice, newTicketsAvailable))
        .to.emit(eventStorage, "EventUpdated")
        .withArgs(0, newTicketPrice, newTicketsAvailable, deployer.address);
    });

    it("should not allow a non-creator to update the event", async function () {
      const { eventManagement, deployer, user1 } = await loadFixture(deployEventManagementFixture);
      const ticketPrice = ethers.parseEther("0.1");
      const ticketsAvailable = 1000;
      await eventManagement.connect(deployer).createEvent(ticketPrice, ticketsAvailable);

      await expect(eventManagement.connect(user1).updateEvent(0, ticketPrice, ticketsAvailable))
        .to.be.revertedWith("Not the event owner");
    });
  });

  describe("Ticket Redemption", function () {
    it("should allow event owner to redeem a ticket", async function () {
      const { eventManagement, eventStorage, ticketStorage, deployer, user1 } = await loadFixture(deployEventManagementFixture);

      await eventManagement.connect(deployer).createEvent(ethers.parseEther("0.1"), 1000);
      await ticketStorage.connect(deployer).createTicket(0, 0, ethers.parseEther("0.1"), user1.address);

      await expect(eventManagement.connect(deployer).redeemTicket(0, 0))
        .to.emit(ticketStorage, "TicketRedeemed")
        .withArgs(0, 0, user1.address, true);
    });

    it("should not allow a non-owner to redeem a ticket", async function () {
      const { eventManagement, ticketStorage, deployer, user1, user2 } = await loadFixture(deployEventManagementFixture);

      await eventManagement.connect(deployer).createEvent(ethers.parseEther("0.1"), 1000);
      await ticketStorage.connect(deployer).createTicket(0, 0, ethers.parseEther("0.1"), user2.address);

      await expect(eventManagement.connect(user1).redeemTicket(0, 0))
        .to.be.revertedWith("Not the event owner");
    });
  });
});
