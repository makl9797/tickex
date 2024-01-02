// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract EventStorage {
    struct EventObject {
        uint256 eventId;
        address owner;
        uint256 ticketPrice;
        uint256 ticketsAvailable;
    }

    EventObject[] public events;
    uint256 public currentEventId;

    constructor() {
        currentEventId = 0;
    }

    function createEvent(
        uint256 ticketPrice,
        uint256 ticketsAvailable,
        address owner
    ) external returns (EventObject memory) {
        EventStorage.EventObject memory eventObject = EventObject({
            eventId: currentEventId,
            owner: owner,
            ticketPrice: ticketPrice,
            ticketsAvailable: ticketsAvailable
        });

        events.push(eventObject);

        currentEventId++;
        return eventObject;
    }

    function updateEvent(
        uint256 eventId,
        uint256 newTicketPrice,
        uint256 newTicketsAvailable
    ) external {
        require(eventId > currentEventId, "Event does not exist.");
        EventObject storage eventObject = events[eventId];

        eventObject.ticketPrice = newTicketPrice;
        eventObject.ticketsAvailable = newTicketsAvailable;
    }

    function getEvent(
        uint256 eventId
    ) external view returns (EventObject memory) {
        require(eventId > currentEventId, "Event does not exist.");
        return events[eventId];
    }
}
