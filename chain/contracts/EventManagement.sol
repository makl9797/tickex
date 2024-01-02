// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./EventStorage.sol";
import "./TicketStorage.sol";

contract EventManagement {
    EventStorage private eventStorage;
    TicketStorage private ticketStorage;

    address public owner;

    constructor(address _eventStorageAddress, address _ticketStorageAddress) {
        eventStorage = EventStorage(_eventStorageAddress);
        ticketStorage = TicketStorage(_ticketStorageAddress);
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Access denied: Not the event owner.");
        _;
    }

    function createEvent(
        uint256 ticketPrice,
        uint256 ticketsAvailable
    ) public onlyOwner {
        eventStorage.createEvent(ticketPrice, ticketsAvailable, owner);
    }

    function updateEvent(
        uint256 eventId,
        uint256 newTicketPrice,
        uint256 newTicketsAvailable
    ) public onlyOwner {
        eventStorage.updateEvent(eventId, newTicketPrice, newTicketsAvailable);
    }

    function redeemTicket(uint256 ticketId) public onlyOwner {
        TicketStorage.Ticket memory ticket = ticketStorage.getTicket(ticketId);
        EventStorage.EventObject memory eventObject = eventStorage
            .getEventObject(ticket.eventId);
        require(
            msg.sender == eventObject.owner,
            "Only event owner can redeem tickets."
        );
        ticketStorage.redeemTicket(ticketId);
    }
}
