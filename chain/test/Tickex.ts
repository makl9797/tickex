import { expect } from "chai";
import { ethers } from "hardhat";
import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";

describe("Tickex", function () {
    async function deployTickexFixture() {
        const Tickex = await ethers.getContractFactory("Tickex");
        const [owner, otherAccount] = await ethers.getSigners();
        const tickex = await Tickex.deploy();

        return { tickex, owner, otherAccount };
    }

    describe("Event Creation", function () {
        it("Should allow owner to create an event", async function () {
            const { tickex, owner } = await loadFixture(deployTickexFixture);
            await expect(tickex.createEvent('Music Festival', 'Outdoor music event', 500, ethers.parseEther('0.05')))
                .to.emit(tickex, 'EventCreated')
                .withArgs(0, 'Music Festival', owner.address);

            const createdEvent = await tickex.getEventDetails(0);
            expect(createdEvent.title).to.equal('Music Festival');
            expect(createdEvent.ticketAnzahl).to.equal(500);
        });

        it("Should not allow other accounts to create events", async function () {
            const { tickex, otherAccount } = await loadFixture(deployTickexFixture);
            await expect(tickex.connect(otherAccount).createEvent('Art Exhibition', 'Art display', 200, ethers.parseEther('0.1')))
                .to.be.revertedWith('Only owner can create events');
        });
    });

    // Hier können Sie weitere Testfälle hinzufügen, um verschiedene Aspekte Ihres Tickex-Vertrags zu überprüfen
});
