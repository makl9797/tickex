defmodule Tickex.Contracts.EventManagement do
  use Ethers.Contract,
    abi_file: "assets/abis/EventManagement.json",
    default_address: "0x5D78981F40447B0619DBc4662cBe72B36D74293b"
end
