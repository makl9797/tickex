import { ethers } from "ethers";
import * as EventManagement from "../../abis/EventManagement.json";
import * as TicketManagement from "../../abis/TicketManagement.json";

const EVENT_MANAGEMENT_ADDRESS = "0x5D78981F40447B0619DBc4662cBe72B36D74293b";
const TICKET_MANAGEMENT_ADDRESS = "0x57C5174960cb239f3eE22dFD659bC56519b81a08";

const web3Provider = new ethers.providers.Web3Provider(window.ethereum);

export const Contracts = {
    mounted() {
        const signer = web3Provider.getSigner();
        const eventManagement = new ethers.Contract(EVENT_MANAGEMENT_ADDRESS, EventManagement.abi, signer);
        const ticketManagement = new ethers.Contract(TICKET_MANAGEMENT_ADDRESS, TicketManagement.abi, signer);

        window.addEventListener(`phx:create-event`, async (e) => {
            try {
                const { ticketPrice, ticketsAvailable } = e.detail;
                const formattedTicketPrice = ethers.utils.parseUnits(ticketPrice.toString(), "ether");
                await eventManagement.createEvent(formattedTicketPrice, ticketsAvailable);
            } catch (error) {
                this.pushEvent("create-event-failed", { error: error.message });
            }
        });

        window.addEventListener(`phx:update-event`, async (e) => {
            try {
                const { eventId, newTicketPrice, newTicketsAvailable } = e.detail;
                const formattedNewTicketPrice = ethers.utils.parseUnits(newTicketPrice.toString(), "ether");
                await eventManagement.updateEvent(eventId, formattedNewTicketPrice, newTicketsAvailable);
            } catch (error) {
                this.pushEvent("update-event-failed", { error: error.message });
            }
        });

        window.addEventListener(`phx:buy-ticket`, async (e) => {
            try {
                const { eventId, ticketPrice } = e.detail;
                const formattedTicketPrice = ethers.utils.parseUnits(ticketPrice.toString(), "ether");
                await ticketManagement.buyTicket(eventId, { value: formattedTicketPrice });
            } catch (error) {
                this.pushEvent("buy-ticket-failed", { error: error.message });
            }
        });

        window.addEventListener(`phx:redeem-ticket`, async (e) => {
            try {
                const { eventId, ticketNumber } = e.detail;
                await eventManagement.redeemTicket(eventId, ticketNumber);
            } catch (error) {
                this.pushEvent("redeem-ticket-failed", { error: error.message });
            }
        });
    },
};

