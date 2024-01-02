defmodule Tickex.Contracts.TicketStorage do
  use Ethers.Contract,
    abi_file: "assets/abis/TicketStorage.json",
    default_address: "0x29f28BeFa781a451725869B9423a6af4BFd16c9F"
end
