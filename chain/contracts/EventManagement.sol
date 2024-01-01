// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./EventStorage.sol";
import "./TicketStorage.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract EventManagement is Initializable, OwnableUpgradeable {
    EventStorage private eventStorage;
    TicketStorage private ticketStorage;

    function initialize(
        address _eventStorageAddress,
        address _ticketStorageAddress
    ) public initializer {
        eventStorage = EventStorage(_eventStorageAddress);
        ticketStorage = TicketStorage(_ticketStorageAddress);
        __Ownable_init();
    }

    function createEvent(uint256 ticketPrice, uint256 ticketsAvailable) public {
        eventStorage.createEvent(ticketPrice, ticketsAvailable);
    }

    function updateEvent(
        uint256 eventId,
        uint256 newTicketPrice,
        uint256 newTicketsAvailable
    ) public {
        EventStorage.EventObject memory eventObject = eventStorage.getEvent(
            eventId
        );
        require(
            msg.sender == eventObject.owner,
            "Only event owner can update the event."
        );
        eventStorage.updateEvent(eventId, newTicketPrice, newTicketsAvailable);
    }

    function redeemTicket(uint256 ticketId) public {
        TicketStorage.Ticket memory ticket = ticketStorage.getTicket(ticketId);
        EventStorage.EventObject memory eventObject = eventStorage.getEvent(
            ticket.eventId
        );
        require(
            msg.sender == eventObject.owner,
            "Only event owner can redeem tickets."
        );
        ticketStorage.redeemTicket(ticketId);
    }
}
