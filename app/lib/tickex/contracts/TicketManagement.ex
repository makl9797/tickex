defmodule Tickex.Contracts.TicketManagement do
  use Ethers.Contract,
    abi_file: "priv/contracts/TicketManagement.json",
    default_address: "0x2814027dAF6B1770ABEbAA4E598A0671285Ab8e6"
end
