// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "hardhat/console.sol";

contract EventStorage {
    struct EventObject {
        uint256 eventId;
        address owner;
        uint256 ticketPrice;
        uint256 ticketsAvailable;
    }

    EventObject[] public events;
    uint256 public currentEventId;

    event EventCreated(
        uint256 indexed eventId,
        uint256 ticketPrice,
        uint256 ticketsAvailable,
        address indexed owner
    );

    event EventUpdated(
        uint256 indexed eventId,
        uint256 ticketPrice,
        uint256 ticketsAvailable,
        address indexed owner
    );

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
        emit EventCreated(currentEventId, ticketPrice, ticketsAvailable, owner);
        currentEventId++;
        return eventObject;
    }

    function updateEvent(
        uint256 eventId,
        uint256 newTicketPrice,
        uint256 newTicketsAvailable
    ) external returns (EventObject memory) {
        require(eventId < currentEventId, "Event does not exist.");
        EventObject storage eventObject = events[eventId];

        eventObject.ticketPrice = newTicketPrice;
        eventObject.ticketsAvailable = newTicketsAvailable;
        emit EventUpdated(
            eventId,
            newTicketPrice,
            newTicketsAvailable,
            eventObject.owner
        );
        return eventObject;
    }

    function getEventObject(
        uint256 eventId
    ) external view returns (EventObject memory) {
        require(eventId < currentEventId, "Event does not exist.");
        return events[eventId];
    }
}
