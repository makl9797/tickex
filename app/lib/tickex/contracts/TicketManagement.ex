defmodule Tickex.Contracts.TicketManagement do
  use Ethers.Contract,
    abi_file: "priv/contracts/TicketManagement.json",
    default_address: "0x95f0D432beB8e08cBbF8516858dF914e6f3d667C"
end
