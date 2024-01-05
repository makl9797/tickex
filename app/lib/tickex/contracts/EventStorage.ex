defmodule Tickex.Contracts.EventStorage do
  use Ethers.Contract,
    abi_file: "assets/abis/EventStorage.json",
    default_address: Application.compile_env(:tickex, :contracts)[:event_storage]
end
