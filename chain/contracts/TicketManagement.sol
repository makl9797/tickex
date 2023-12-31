// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./EventStorage.sol";
import "./TicketStorage.sol";

contract TicketManagement {
    EventStorage private eventStorage;
    TicketStorage private ticketStorage;

    constructor(address _eventStorageAddress, address _ticketStorageAddress) {
        eventStorage = EventStorage(_eventStorageAddress);
        ticketStorage = TicketStorage(_ticketStorageAddress);
    }

    function buyTicket(uint256 eventId) public payable {
        EventStorage.EventObject memory eventObject = eventStorage
            .getEventObject(eventId);
        require(eventObject.ticketsAvailable > 0, "No tickets available.");
        require(
            msg.value == eventObject.ticketPrice,
            "Incorrect ticket price."
        );

        uint256 ticketNumber = ticketStorage.getTicketCountForEvent(eventId);

        ticketStorage.createTicket(
            eventId,
            ticketNumber,
            eventObject.ticketPrice,
            msg.sender
        );

        eventStorage.updateEvent(
            eventId,
            eventObject.ticketPrice,
            eventObject.ticketsAvailable - 1
        );

        payable(eventObject.owner).transfer(msg.value);
    }
}
