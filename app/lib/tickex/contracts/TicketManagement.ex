defmodule Tickex.Contracts.TicketManagement do
  use Ethers.Contract,
    abi_file: "assets/abis/TicketManagement.json",
    default_address: "0x57C5174960cb239f3eE22dFD659bC56519b81a08"
end
