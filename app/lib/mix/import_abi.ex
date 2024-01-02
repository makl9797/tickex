defmodule Mix.Tasks.ImportAbi do
  use Mix.Task
  @shortdoc "Imports ABI JSONs and generates Elixir Contract modules."

  @moduledoc """
  This task imports ABI JSON files from the Hardhat artifacts folder and generates
  Elixir modules for interacting with smart contracts.

  ## Usage

      mix import_abi --contracts "EventManagement,EventStorage" --artifacts_path "../chain/artifacts"

  ## Parameters

  - `--contracts`: A comma-separated list of contract names for which modules should be generated.
  - `--artifacts_path`: The relative path to the Hardhat artifacts folder.
  """

  @impl true
  def run(args) do
    {contracts, artifacts_path} = parse_args(args)

    Enum.each(contracts, &generate_contract_module(&1, artifacts_path))

    IO.puts("Contract modules have been generated and ABI JSONs imported.")
  end

  defp parse_args(args) do
    {opts, _, _} =
      OptionParser.parse(args,
        switches: [contracts: :string, artifacts_path: :string]
      )

    contracts = parse_contracts(opts[:contracts])
    artifacts_path = opts[:artifacts_path] || raise "Please provide --artifacts_path option."

    {contracts, artifacts_path}
  end

  defp parse_contracts(nil), do: raise "Please provide --contracts option."
  defp parse_contracts(contracts) do
    contracts
    |> String.replace(["[", "]"], "")
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
  end

  defp generate_contract_module(contract_name, artifacts_path) do
    File.mkdir_p("lib/tickex/contracts")
    File.mkdir_p("priv/contracts")

    create_contract_module(contract_name)
    copy_abi_json(contract_name, artifacts_path)
  end

  defp create_contract_module(contract_name) do
    content = """
    defmodule Tickex.Contracts.#{contract_name} do
      use Ethers.Contract,
        abi_file: "priv/contracts/#{contract_name}.json",
        default_address: "<Fill in contract address>"
    end
    """

    File.write!("lib/tickex/contracts/#{contract_name}.ex", content)
  end

  defp copy_abi_json(contract_name, artifacts_path) do
    source_path = Path.join([artifacts_path, "contracts", "#{contract_name}.sol", "#{contract_name}.json"])

    if File.exists?(source_path) do
      dest_path = "priv/contracts/#{contract_name}.json"
      File.cp!(source_path, dest_path)
    else
      Mix.raise("Could not find ABI JSON for #{contract_name} at #{source_path}")
    end
  end
end
