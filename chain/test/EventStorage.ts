import { ethers } from "hardhat";
import { expect } from "chai";
import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";

describe("EventStorage Contract", function () {
  async function deployEventStorageFixture() {
    const [owner, user1] = await ethers.getSigners();

    const EventStorage = await ethers.getContractFactory("EventStorage");
    const eventStorage = await EventStorage.deploy();

    return { eventStorage, owner, user1 };
  }

  describe("Event Creation", function () {
    it("should allow users to create an event", async function () {
      const { eventStorage, owner } = await loadFixture(deployEventStorageFixture);

      await expect(eventStorage.createEvent(100, 1000, owner.address))
        .to.emit(eventStorage, "EventCreated")
        .withArgs(0, 100, 1000, owner.address);
    });
  });

  describe("Event Update", function () {
    it("should allow the event owner to update the event", async function () {
      const { eventStorage, owner } = await loadFixture(deployEventStorageFixture);
      await eventStorage.createEvent(100, 1000, owner.address);
      await expect(eventStorage.updateEvent(0, 150, 900))
        .to.emit(eventStorage, "EventUpdated")
        .withArgs(0, 150, 900, owner.address);
    });
  });

  describe("Get Event", function () {
    it("should return the correct event details", async function () {
      const { eventStorage, owner } = await loadFixture(deployEventStorageFixture);

      await eventStorage.createEvent(100, 1000, owner.address);

      const event = await eventStorage.getEventObject(0);

      expect(event.owner).to.equal(owner.address);
      expect(event.ticketPrice).to.equal(100);
      expect(event.ticketsAvailable).to.equal(1000);
    });

    it("should revert if the event does not exist", async function () {
      const { eventStorage } = await loadFixture(deployEventStorageFixture);

      await expect(eventStorage.getEventObject(999))
        .to.be.revertedWith("Event does not exist.");
    });
  });

  
});
