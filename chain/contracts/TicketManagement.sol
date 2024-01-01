// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./EventStorage.sol";
import "./TicketStorage.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract TicketManagement is Initializable {
    EventStorage private eventStorage;
    TicketStorage private ticketStorage;

    function initialize(
        address _eventStorageAddress,
        address _ticketStorageAddress
    ) public initializer {
        eventStorage = EventStorage(_eventStorageAddress);
        ticketStorage = TicketStorage(_ticketStorageAddress);
    }

    function buyTicket(uint256 eventId) public payable {
        EventStorage.EventObject memory eventObject = eventStorage.getEvent(
            eventId
        );
        require(eventObject.ticketsAvailable > 0, "No tickets available.");
        require(
            msg.value == eventObject.ticketPrice,
            "Incorrect ticket price."
        );

        ticketStorage.createTicket(eventId, msg.sender);

        // Reduzieren Sie die Anzahl der verfügbaren Tickets
        eventStorage.updateEvent(
            eventId,
            eventObject.ticketPrice,
            eventObject.ticketsAvailable - 1
        );

        // Überweisung des Geldes an den Eventersteller
        payable(eventObject.owner).transfer(msg.value);
    }
}
