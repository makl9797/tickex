// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./EventStorage.sol";
import "./TicketStorage.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract EventManagement is Initializable, OwnableUpgradeable {
    EventStorage private eventStorage;
    TicketStorage private ticketStorage;

    function initialize(address _eventStorageAddress, address _ticketStorageAddress) public initializer {
        __Ownable_init();
        eventStorage = EventStorage(_eventStorageAddress);
        ticketStorage = TicketStorage(_ticketStorageAddress);
    }

    function createEvent(uint256 ticketPrice, uint256 ticketsAvailable) public onlyOwner {
        eventStorage.createEvent(ticketPrice, ticketsAvailable);
    }

    function redeemTicket(uint256 ticketId) public {
        TicketStorage.Ticket memory ticket = ticketStorage.getTicket(ticketId);
        EventStorage.Event memory event = eventStorage.getEvent(ticket.eventId);
        require(msg.sender == event.owner, "Only event owner can redeem tickets.");
        ticketStorage.redeemTicket(ticketId);
    }
}
