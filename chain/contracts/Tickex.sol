// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Tickex {
    struct Event {
        uint256 eventID;
        string title;
        string description;
        uint256 ticketAnzahl;
        uint256 ticketPreis;
        address erstellerAdresse;
        uint256 verkaufterTickets;
    }

    address public owner;
    Event[] public events;
    uint256 public nextEventId;

    event EventCreated(uint256 eventId, string title, address indexed owner);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can create events");
        _;
    }

    function createEvent(
        string memory title,
        string memory description,
        uint256 ticketAnzahl,
        uint256 ticketPreis
    ) public onlyOwner {
        events.push(
            Event(
                nextEventId,
                title,
                description,
                ticketAnzahl,
                ticketPreis,
                msg.sender,
                0
            )
        );
        emit EventCreated(nextEventId, title, msg.sender);
        nextEventId++;
    }

    function getEventDetails(
        uint256 eventId
    ) public view returns (Event memory) {
        require(eventId < events.length, "Event does not exist.");
        return events[eventId];
    }
}
