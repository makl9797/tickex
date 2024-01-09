defmodule Tickex.Events.Event do
  use Ecto.Schema
  import Ecto.Changeset

  alias Tickex.Accounts.User
  alias Tickex.Events.Ticket

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "events" do
    field(:title, :string)
    field(:description, :string)
    field(:location, :string)

    # Contract fields
    field(:contract_event_id, :integer)
    field(:ticket_price, :float)
    field(:number_of_tickets, :integer)

    field(:has_on_chain_changes, :boolean, virtual: true, default: false)

    belongs_to(:owner, User)
    has_many :tickets, Ticket

    timestamps(type: :utc_datetime)
  end

  @required_fields ~w[title ticket_price number_of_tickets]a
  @optional_fields ~w[description location contract_event_id]a

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> check_for_on_chain_changes([:ticket_price, :number_of_tickets])
  end

  defp check_for_on_chain_changes(changeset, fields) do
    has_on_chain_changes =
      Enum.reduce(fields, false, fn
        field, false -> changed?(changeset, field)
        _field, acc -> acc
      end)

    put_change(changeset, :has_on_chain_changes, has_on_chain_changes)
  end
end
