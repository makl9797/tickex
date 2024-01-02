defmodule Mix.Tasks.ImportAbi do
  use Mix.Task
  @shortdoc "Generates Elixir Contract modules based on ABI JSON filenames in 'priv/contracts'."

  @moduledoc """
  This task generates Elixir modules for interacting with smart contracts based on ABI JSON filenames located in 'priv/contracts'.

  ## Usage

      mix import_abi
  """

  @impl true
  def run(_args) do
    contracts = get_contract_names_from_abi_files()

    Enum.each(contracts, &create_contract_module/1)

    IO.puts("Contract modules have been generated.")
  end

  defp get_contract_names_from_abi_files do
    Path.wildcard("priv/contracts/*.json")
    |> Enum.map(&Path.basename(&1, ".json"))
  end

  defp create_contract_module(contract_name) do
    File.mkdir_p("lib/tickex/contracts")

    content = """
    defmodule Tickex.Contracts.#{contract_name} do
      use Ethers.Contract,
        abi_file: "priv/contracts/#{contract_name}.json",
        default_address: "<Fill in contract address>"
    end
    """

    File.write!("lib/tickex/contracts/#{contract_name}.ex", content)
  end
end
