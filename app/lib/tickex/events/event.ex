defmodule Tickex.Events.Event do
  alias Tickex.Accounts.User
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "events" do
    field(:title, :string)
    field(:description, :string)
    field(:location, :string)
    field(:creation_date, :utc_datetime)

    # Contract fields
    field(:contract_event_id, :integer)
    field(:ticket_price, :float)
    field(:number_of_tickets, :integer)

    belongs_to(:owner, User)

    timestamps(type: :utc_datetime)
  end

  @required_fields ~w[title creation_date contract_event_id ticket_price number_of_tickets]a
  @optional_fields ~w[description location]a

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
