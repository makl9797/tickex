import { ethers } from "ethers";
import EventManagementAbi from "../abis/EventManagement.json";
import TicketManagementAbi from "../abis/TicketManagement.json";

const EVENT_MANAGEMENT_ADDRESS = "0x91cA0DaA14c1aae433de956d4E10cd60d36E995a";
const TICKET_MANAGEMENT_ADDRESS = "0x2814027dAF6B1770ABEbAA4E598A0671285Ab8e6";

const web3Provider = new ethers.providers.Web3Provider(window.ethereum);

export const Contracts = {
    mounted() {
        const signer = web3Provider.getSigner();
        const eventManagement = new ethers.Contract(EVENT_MANAGEMENT_ADDRESS, EventManagementAbi, signer);
        const ticketManagement = new ethers.Contract(TICKET_MANAGEMENT_ADDRESS, TicketManagementAbi, signer);

        window.addEventListener(`phx:create-event`, async (e) => {
            const { ticketPrice, ticketsAvailable } = e.detail;
            await eventManagement.createEvent(ethers.utils.parseUnits(ticketPrice, "matic"), ticketsAvailable);
        });

        window.addEventListener(`phx:buy-ticket`, async (e) => {
            const { eventId, ticketPrice } = e.detail;
            await ticketManagement.buyTicket(eventId, { value: ethers.utils.parseUnits(ticketPrice, "matic") });
        });

        window.addEventListener(`phx:redeem-ticket`, async (e) => {
            const { eventId, ticketNumber } = e.detail;
            await ticketManagement.redeemTicket(eventId, ticketNumber);
        });
    },
};
