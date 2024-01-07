defmodule Tickex.Repo.Migrations.RemovePurchaseDateForTickets do
  use Ecto.Migration

  def change do
    alter table(:tickets) do
      remove(:purchase_date)
    end
  end
end
