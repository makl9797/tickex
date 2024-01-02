defmodule Tickex.Contracts.EventManagement do
  use Ethers.Contract,
    abi_file: "priv/contracts/EventManagement.json",
    default_address: "0x91cA0DaA14c1aae433de956d4E10cd60d36E995a"
end
