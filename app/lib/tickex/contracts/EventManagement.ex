defmodule Tickex.Contracts.EventManagement do
  use Ethers.Contract,
    abi_file: "assets/abis/EventManagement.json",
    default_address: Application.compile_env(:tickex, :contracts)[:event_management]
end
