// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract TicketStorage {
    struct Ticket {
        uint256 ticketNumber;
        uint256 eventId;
        uint256 price;
        address owner;
        bool isRedeemed;
    }

    mapping(uint256 => mapping(uint256 => Ticket)) private tickets;
    mapping(uint256 => uint256) private ticketCountPerEvent;

    event TicketCreated(
        uint256 indexed ticketNumber,
        uint256 indexed eventId,
        uint256 price,
        address indexed owner,
        bool isRedeemed
    );

    event TicketRedeemed(
        uint256 indexed ticketNumber,
        uint256 indexed eventId,
        address indexed owner,
        bool isRedeemed
    );

    function createTicket(
        uint256 eventId,
        uint256 ticketNumber,
        uint256 price,
        address owner
    ) external returns (Ticket memory) {
        Ticket memory newTicket = Ticket({
            ticketNumber: ticketNumber,
            eventId: eventId,
            price: price,
            owner: owner,
            isRedeemed: false
        });

        tickets[eventId][ticketNumber] = newTicket;
        ticketCountPerEvent[eventId]++;
        emit TicketCreated(
            newTicket.ticketNumber,
            newTicket.eventId,
            newTicket.price,
            newTicket.owner,
            newTicket.isRedeemed
        );
        return newTicket;
    }

    function redeemTicket(
        uint256 eventId,
        uint256 ticketNumber
    ) external returns (Ticket memory) {
        require(
            ticketNumber < ticketCountPerEvent[eventId],
            "Ticket does not exist."
        );
        Ticket storage ticket = tickets[eventId][ticketNumber];
        require(!ticket.isRedeemed, "Ticket already redeemed.");
        ticket.isRedeemed = true;
        emit TicketRedeemed(
            ticketNumber,
            eventId,
            ticket.owner,
            ticket.isRedeemed
        );

        return ticket;
    }

    function getTicket(
        uint256 eventId,
        uint256 ticketNumber
    ) external view returns (Ticket memory) {
        require(
            ticketNumber < ticketCountPerEvent[eventId],
            "Ticket does not exist."
        );
        Ticket memory ticket = tickets[eventId][ticketNumber];
        return ticket;
    }

    function getTicketCountForEvent(
        uint256 eventId
    ) external view returns (uint256) {
        return ticketCountPerEvent[eventId];
    }
}
