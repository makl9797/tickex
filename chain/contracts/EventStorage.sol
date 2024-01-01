// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract EventStorage is Initializable {
    struct EventObject {
        address owner;
        uint256 ticketPrice;
        uint256 ticketsAvailable;
    }

    EventObject[] public events;

    function initialize() public initializer {}

    function createEvent(
        uint256 ticketPrice,
        uint256 ticketsAvailable
    ) external {
        events.push(
            EventObject({
                owner: msg.sender,
                ticketPrice: ticketPrice,
                ticketsAvailable: ticketsAvailable
            })
        );
    }

    function updateEvent(
        uint256 eventId,
        uint256 newTicketPrice,
        uint256 newTicketsAvailable
    ) external {
        require(eventId < events.length, "Event does not exist.");
        EventObject storage eventObject = events[eventId];
        require(
            msg.sender == eventObject.owner,
            "Only event owner can update the event."
        );

        eventObject.ticketPrice = newTicketPrice;
        eventObject.ticketsAvailable = newTicketsAvailable;
    }

    function getEvent(
        uint256 eventId
    ) external view returns (EventObject memory) {
        require(eventId < events.length, "Event does not exist.");
        return events[eventId];
    }
}
