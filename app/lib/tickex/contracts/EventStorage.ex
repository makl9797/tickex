defmodule Tickex.Contracts.EventStorage do
  use Ethers.Contract,
    abi_file: "assets/abis/EventStorage.json",
    default_address: "0x96953A9A83Dc5bf98617d2BadAB18E5825DE9606"
end
