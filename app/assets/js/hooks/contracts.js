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


        this.handleEvent("create-event", data => {
            try {
                const { ticketPrice, ticketsAvailable } = data;
                const formattedTicketPrice = ethers.utils.parseUnits(ticketPrice.toString(), "ether");
                await eventManagement.createEvent(formattedTicketPrice, ticketsAvailable);
            } catch (error) {
                this.pushEvent("failed-create-event", { error: error.message });
            }
        });

        this.handleEvent("update-event", data => {
            try {
                const { eventId, newTicketPrice, newTicketsAvailable } = data;
                const formattedNewTicketPrice = ethers.utils.parseUnits(newTicketPrice.toString(), "ether");
                await eventManagement.updateEvent(eventId, formattedNewTicketPrice, newTicketsAvailable);
            } catch (error) {
                this.pushEvent("failed-update-event", { error: error.message });
            }
        });

        this.handleEvent("buy-ticket", data => {
            try {
                const { eventId, ticketPrice } = data;
                const formattedTicketPrice = ethers.utils.parseUnits(ticketPrice.toString(), "ether");
                await ticketManagement.buyTicket(eventId, { value: formattedTicketPrice });
            } catch (error) {
                this.pushEvent("failed-buy-ticket", { error: error.message });
            }
        });

        this.handleEvent("redeem-ticket", data => {
            try {
                const { eventId, ticketNumber } = data;
                await eventManagement.redeemTicket(eventId, ticketNumber);
            } catch (error) {
                this.pushEvent("failed-redeem-ticket", { error: error.message });
            }
        });
    },
};

