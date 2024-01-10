defmodule Tickex.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string
      add :description, :text
      add :location, :string
      add :creation_date, :utc_datetime

      timestamps(type: :utc_datetime)
    end
  end
end
