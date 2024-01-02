import { ethers } from "hardhat";
import { expect } from "chai";
import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";

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
      const { eventManagement, owner } = await loadFixture(deployEventManagementFixture);

      await expect(eventManagement.createEvent(100, 1000))
        .to.emit(eventManagement, "EventCreated")
        .withArgs(0, 100, 1000, owner.address);
    });
  });

  describe("Event Update", function () {
    it("should allow the owner to update an event", async function () {
      const { eventManagement, eventStorage, owner } = await loadFixture(deployEventManagementFixture);

      await eventManagement.createEvent(100, 1000);
      await expect(eventManagement.updateEvent(0, 150, 900))
        .to.emit(eventStorage, "EventUpdated")
        .withArgs(0, 150, 900);
    });

    it("should not allow a non-owner to update an event", async function () {
      const { eventManagement, eventStorage, owner, user1 } = await loadFixture(deployEventManagementFixture);

      await eventManagement.createEvent(100, 1000);
      await expect(eventManagement.connect(user1).updateEvent(0, 150, 900))
        .to.be.revertedWith("Only event owner can update the event.");
    });
  });

  describe("Ticket Redemption", function () {
    it("should allow ticket redemption by the event owner", async function () {
      const { eventManagement, ticketStorage, owner } = await loadFixture(deployEventManagementFixture);

      await eventManagement.createEvent(100, 1000);
      await expect(eventManagement.redeemTicket(0))
        .to.emit(ticketStorage, "TicketRedeemed")
        .withArgs(0);
    });

    it("should not allow ticket redemption by a non-owner", async function () {
      const { eventManagement, ticketStorage, owner, user1 } = await loadFixture(deployEventManagementFixture);

      await eventManagement.createEvent(100, 1000);
      await expect(eventManagement.connect(user1).redeemTicket(0))
        .to.be.revertedWith("Only event owner can redeem tickets.");
    });
  });

  // Weitere Tests können hier hinzugefügt werden...
});
