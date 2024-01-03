import { ethers } from "ethers";
import * as EventManagement from "../../abis/EventManagement.json";
import * as TicketManagement from "../../abis/TicketManagement.json";

const EVENT_MANAGEMENT_ADDRESS = "0x91cA0DaA14c1aae433de956d4E10cd60d36E995a";
const TICKET_MANAGEMENT_ADDRESS = "0x2814027dAF6B1770ABEbAA4E598A0671285Ab8e6";

const web3Provider = new ethers.providers.Web3Provider(window.ethereum);

export const Contracts = {
    mounted() {
        const signer = web3Provider.getSigner();
        const eventManagement = new ethers.Contract(EVENT_MANAGEMENT_ADDRESS, EventManagement.abi, signer);
        const ticketManagement = new ethers.Contract(TICKET_MANAGEMENT_ADDRESS, TicketManagement.abi, signer);

        window.addEventListener(`phx:create-event`, async (e) => {
            const { ticketPrice, ticketsAvailable } = e.detail;
            const formattedTicketPrice = ethers.utils.parseUnits(ticketPrice.toString(), "ether");
            const event = await eventManagement.createEvent(formattedTicketPrice, ticketsAvailable);
        });

        window.addEventListener(`phx:buy-ticket`, async (e) => {
            const { eventId, ticketPrice } = e.detail;
            const formattedTicketPrice = ethers.utils.parseUnits(ticketPrice.toString(), "ether");
            await ticketManagement.buyTicket(eventId, { value: formattedTicketPrice });
        });

        window.addEventListener(`phx:redeem-ticket`, async (e) => {
            const { eventId, ticketNumber } = e.detail;
            await ticketManagement.redeemTicket(eventId, ticketNumber);
        });
    },
};
