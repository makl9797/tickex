defmodule Tickex.Contracts.EventManagement do
  use Ethers.Contract,
    abi_file: "priv/contracts/EventManagement.json",
    default_address: "0x3bc8AaA88d3ABaf359AaDAe4C9112187f8E62ea0"
end
