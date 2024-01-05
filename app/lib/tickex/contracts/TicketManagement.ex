defmodule Tickex.Contracts.TicketManagement do
  use Ethers.Contract,
    abi_file: "assets/abis/TicketManagement.json",
    default_address: Application.compile_env(:tickex, :contracts)[:ticket_management]
end
