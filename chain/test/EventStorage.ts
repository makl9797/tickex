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

      await expect(eventStorage.createEvent(100, 1000))
        .to.emit(eventStorage, "EventCreated")
        .withArgs(0, owner.address, 100, 1000);
    });
  });

  describe("Event Update", function () {
    it("should allow the event owner to update the event", async function () {
      const { eventStorage, owner } = await loadFixture(deployEventStorageFixture);

      await eventStorage.createEvent(100, 1000);
      await expect(eventStorage.updateEvent(0, 150, 900))
        .to.emit(eventStorage, "EventUpdated")
        .withArgs(0, 150, 900);
    });

    it("should not allow a non-owner to update the event", async function () {
      const { eventStorage, owner, user1 } = await loadFixture(deployEventStorageFixture);

      await eventStorage.createEvent(100, 1000);
      await expect(eventStorage.connect(user1).updateEvent(0, 150, 900))
        .to.be.revertedWith("You do not own this event.");
    });
  });

  describe("Get Event", function () {
    it("should return the correct event details", async function () {
      const { eventStorage, owner } = await loadFixture(deployEventStorageFixture);

      await eventStorage.createEvent(100, 1000);
      const event = await eventStorage.getEvent(0);

      expect(event.owner).to.equal(owner.address);
      expect(event.ticketPrice).to.equal(100);
      expect(event.ticketsAvailable).to.equal(1000);
    });

    it("should revert if the event does not exist", async function () {
      const { eventStorage } = await loadFixture(deployEventStorageFixture);

      await expect(eventStorage.getEvent(999))
        .to.be.revertedWith("Event does not exist.");
    });
  });

  // Weitere Tests können hier hinzugefügt werden...
});
