defmodule Tickex.Contracts.TicketStorage do
  use Ethers.Contract,
    abi_file: "assets/abis/TicketStorage.json",
    default_address: Application.compile_env(:tickex, :contracts)[:ticket_storage]
end
