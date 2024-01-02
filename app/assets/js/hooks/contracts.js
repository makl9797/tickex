import { ethers } from "ethers";

// Import ABIs
import EventManagementAbi from "./abis/EventManagement.json";
import TicketManagementAbi from "./abis/TicketManagement.json";

// Define contract addresses (replace with actual addresses)
const EVENT_MANAGEMENT_ADDRESS = "0xYourEventManagementContractAddress";
const TICKET_MANAGEMENT_ADDRESS = "0xYourTicketManagementContractAddress";

const web3Provider = new ethers.providers.Web3Provider(window.ethereum);

export const Contracts = {
    mounted() {
        const signer = web3Provider.getSigner();

        // Create contract instances
        const eventManagement = new ethers.Contract(EVENT_MANAGEMENT_ADDRESS, EventManagementAbi, signer);
        const ticketManagement = new ethers.Contract(TICKET_MANAGEMENT_ADDRESS, TicketManagementAbi, signer);

        window.addEventListener(`phx:create-event`, async (e) => {
            const { ticketPrice, ticketsAvailable } = e.detail;
            await eventManagement.createEvent(ethers.utils.parseUnits(ticketPrice, "ether"), ticketsAvailable);
        });

        window.addEventListener(`phx:buy-ticket`, async (e) => {
            const { eventId, ticketPrice } = e.detail;
            await ticketManagement.buyTicket(eventId, { value: ethers.utils.parseUnits(ticketPrice, "ether") });
        });

        window.addEventListener(`phx:redeem-ticket`, async (e) => {
            const { eventId, ticketNumber } = e.detail;
            await ticketManagement.redeemTicket(eventId, ticketNumber);
        });
    },
};
