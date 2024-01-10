defmodule Tickex.Events.Ticket do
  use Ecto.Schema
  import Ecto.Changeset

  alias Tickex.Accounts.User
  alias Tickex.Events.Event

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tickets" do
    field(:contract_ticket_id, :integer)
    field(:purchase_price, :float)
    field(:redeemed, :boolean, default: false)

    belongs_to(:event, Event)
    belongs_to(:buyer, User)

    timestamps(type: :utc_datetime)
  end

  @required_fields ~w[purchase_price redeemed]a
  @optional_fields ~w[contract_ticket_id]a

  @doc false
  def changeset(ticket, attrs) do
    ticket
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
