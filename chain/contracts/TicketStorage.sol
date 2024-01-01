// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract TicketStorage {
    struct Ticket {
        uint256 eventId;
        address owner;
        bool isRedeemed;
    }

    Ticket[] public tickets;

    function createTicket(uint256 eventId, address owner) external {
        tickets.push(
            Ticket({eventId: eventId, owner: owner, isRedeemed: false})
        );
    }

    function redeemTicket(uint256 ticketId) external {
        Ticket storage ticket = tickets[ticketId];
        require(!ticket.isRedeemed, "Ticket already redeemed.");
        ticket.isRedeemed = true;
    }

    function getTicket(uint256 ticketId) external view returns (Ticket memory) {
        require(ticketId < tickets.length, "Ticket does not exist.");
        return tickets[ticketId];
    }
}
