// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./EventStorage.sol";
import "./TicketStorage.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract TicketManagement is Initializable {
    EventStorage private eventStorage;
    TicketStorage private ticketStorage;

    function initialize(address _eventStorageAddress, address _ticketStorageAddress) public initializer {
        eventStorage = EventStorage(_eventStorageAddress);
        ticketStorage = TicketStorage(_ticketStorageAddress);
    }

    function buyTicket(uint256 eventId) public payable {
        EventStorage.Event memory event = eventStorage.getEvent(eventId);
        require(event.ticketsAvailable > 0, "No tickets available.");
        require(msg.value == event.ticketPrice, "Incorrect ticket price.");
        
        ticketStorage.createTicket(eventId, msg.sender);
        // Weitere Logik zur Aktualisierung der verfügbaren Tickets und Überweisung des Geldes an den Eventersteller.
    }
}
