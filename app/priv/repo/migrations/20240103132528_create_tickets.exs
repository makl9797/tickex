defmodule Tickex.Repo.Migrations.CreateTickets do
  use Ecto.Migration

  def change do
    create table(:tickets, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :purchase_date, :utc_datetime
      add :redeemed, :boolean, default: false, null: false
      add :event_id, references(:events, on_delete: :nothing, type: :binary_id)
      add :buyer_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:tickets, [:event_id])
    create index(:tickets, [:buyer_id])
  end
end
