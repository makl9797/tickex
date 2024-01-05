defmodule Tickex.Repo.Migrations.CreateTicketsAndAdjustEvents do
  use Ecto.Migration

  def change do
    alter table(:events) do
      add(:contract_event_id, :integer)
      add(:ticket_price, :float)
      add(:number_of_tickets, :integer)
      add(:owner_id, references(:users, on_delete: :nothing, type: :binary_id))
    end

    create(index(:events, [:owner_id]))

    create table(:tickets, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:contract_ticket_id, :integer)
      add(:purchase_date, :utc_datetime)
      add(:purchase_price, :float)
      add(:redeemed, :boolean, default: false, null: false)
      add(:event_id, references(:events, on_delete: :nothing, type: :binary_id))
      add(:buyer_id, references(:users, on_delete: :nothing, type: :binary_id))

      timestamps(type: :utc_datetime)
    end

    create(index(:tickets, [:event_id]))
    create(index(:tickets, [:buyer_id]))
  end
end
