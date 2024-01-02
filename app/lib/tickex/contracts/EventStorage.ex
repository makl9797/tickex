defmodule Tickex.Contracts.EventStorage do
  use Ethers.Contract,
    abi_file: "priv/contracts/EventStorage.json",
    default_address: "0xc15Bb4a76BC0a087f3039F975BAA97721d493918"
end
