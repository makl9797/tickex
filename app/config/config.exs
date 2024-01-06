# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :tickex,
  ecto_repos: [Tickex.Repo],
  generators: [timestamp_type: :utc_datetime, binary_id: true]

# Configures the endpoint
config :tickex, TickexWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: TickexWeb.ErrorHTML, json: TickexWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Tickex.PubSub,
  live_view: [signing_salt: "tvYT3nWo"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{
      "NODE_PATH" => Path.expand("../deps", __DIR__),
      "EVENT_MANAGEMENT_CONTACT_ADDRESS" => System.get_env("EVENT_MANAGEMENT_CONTACT_ADDRESS"),
      "TICKET_MANAGEMENT_CONTACT_ADDRESS" => System.get_env("TICKET_MANAGEMENT_CONTACT_ADDRESS")
    }
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.3.2",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

config :ethers,
  rpc_client: Ethereumex.HttpClient,
  keccak_module: ExKeccak,
  json_module: Jason,
  secp256k1_module: ExSecp256k1,
  default_signer: nil,
  default_signer_opts: []

config :tickex, :contracts,
  event_storage: System.get_env("EVENT_STORAGE_CONTRACT_ADDRESS") || "",
  event_management: System.get_env("EVENT_MANAGEMENT_CONTRACT_ADDRESS") || "",
  ticket_storage: System.get_env("TICKET_STORAGE_CONTRACT_ADDRESS") || "",
  ticket_management: System.get_env("TICKET_MANAGEMENT_CONTRACT_ADDRESS") || ""

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
