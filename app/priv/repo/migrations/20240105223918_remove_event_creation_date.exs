defmodule Tickex.Repo.Migrations.RemoveEventCreationDate do
  use Ecto.Migration

  def change do
    alter table(:events) do
      remove(:creation_date)
    end
  end
end
