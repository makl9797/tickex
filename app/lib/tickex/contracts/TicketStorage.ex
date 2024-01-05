defmodule Tickex.Contracts.TicketStorage do
  use Ethers.Contract,
    abi_file: "assets/abis/TicketStorage.json",
    default_address: "0x30fc58E2Bb6f3CB01c70fCE440829f1D206B0512"
end
