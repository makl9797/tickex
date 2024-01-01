// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract EventStorage is Initializable {
    struct Event {
        address owner;
        uint256 ticketPrice;
        uint256 ticketsAvailable;
    }

    Event[] public events;

    function initialize() public initializer {
    }

    function createEvent(uint256 ticketPrice, uint256 ticketsAvailable) external {
        events.push(Event({
            owner: msg.sender,
            ticketPrice: ticketPrice,
            ticketsAvailable: ticketsAvailable
        }));
    }

    function getEvent(uint256 eventId) external view returns (Event memory) {
        require(eventId < events.length, "Event does not exist.");
        return events[eventId];
    }
}
