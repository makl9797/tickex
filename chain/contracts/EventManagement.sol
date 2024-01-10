// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./EventStorage.sol";
import "./TicketStorage.sol";

contract EventManagement {
    EventStorage private eventStorage;
    TicketStorage private ticketStorage;

    constructor(address _eventStorageAddress, address _ticketStorageAddress) {
        eventStorage = EventStorage(_eventStorageAddress);
        ticketStorage = TicketStorage(_ticketStorageAddress);
    }

    function createEvent(uint256 ticketPrice, uint256 ticketsAvailable) public {
        eventStorage.createEvent(ticketPrice, ticketsAvailable, msg.sender);
    }

    function updateEvent(
        uint256 eventId,
        uint256 newTicketPrice,
        uint256 newTicketsAvailable
    ) public {
        EventStorage.EventObject memory eventObject = eventStorage
            .getEventObject(eventId);
        require(eventObject.owner == msg.sender, "Not the event owner");
        eventStorage.updateEvent(eventId, newTicketPrice, newTicketsAvailable);
    }

    function redeemTicket(uint256 eventId, uint256 ticketNumber) public {
        EventStorage.EventObject memory eventObject = eventStorage
            .getEventObject(eventId);
        require(eventObject.owner == msg.sender, "Not the event owner");
        ticketStorage.redeemTicket(eventId, ticketNumber);
    }
}
