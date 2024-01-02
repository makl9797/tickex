defmodule Tickex.Contracts.TicketStorage do
  use Ethers.Contract,
    abi_file: "priv/contracts/TicketStorage.json",
    default_address: "0x64d8a35DCD437437499A13bc9788385049F44bB8"
end
