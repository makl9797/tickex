defmodule Tickex.Repo do
  use Ecto.Repo,
    otp_app: :tickex,
    adapter: Ecto.Adapters.Postgres
end
