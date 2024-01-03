defmodule Tickex.Events.Ticket do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tickets" do
    field :purchase_date, :utc_datetime
    field :redeemed, :boolean, default: false
    field :event_id, :binary_id
    field :buyer_id, :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(ticket, attrs) do
    ticket
    |> cast(attrs, [:purchase_date, :redeemed])
    |> validate_required([:purchase_date, :redeemed])
  end
end
