defmodule Tickex.Contracts.EventStorage do
  use Ethers.Contract,
    abi_file: "priv/contracts/EventStorage.json",
    default_address: "0xC204c948ff431e81fd6D41e60D90e118fFBeD5f0"
end
