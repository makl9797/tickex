defmodule Tickex.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias Tickex.Events.{Event, Ticket}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field(:wallet_address, :string)
    field(:nonce, :string)
    field(:name, :string)
    field(:email, :string)
    field(:registration_date, :naive_datetime)

    has_many(:tickets, Ticket)
    has_many(:events, Event)

    timestamps(type: :utc_datetime)
  end

  @doc """
  A user changeset for registration.

  It is important to validate the length of the email.
  Otherwise databases may truncate the email without warnings, which
  could lead to unpredictable or insecure behaviour.

  ## Options

    * `:validate_email` - Validates the uniqueness of the email, in case
      you don't want to validate the uniqueness of the email (like when
      using this changeset for validations on a LiveView form before
      submitting the form), this option can be set to `false`.
      Defaults to `true`.
  """

  # def registration_changeset(user, attrs, opts \\ []) do
  #   user
  #   |> cast(attrs, [:email])
  #   |> validate_email(opts)
  # end

  @required_fields ~w[wallet_address nonce registration_date]a
  @optional_fields ~w[name email]a

  def registration_changeset(user, attrs \\ %{}) do
    user
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint([:wallet_address])
  end

  def update_changeset(user, attrs \\ %{}) do
    user
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required([:nonce])
  end

  defp validate_email(changeset, opts) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
    |> maybe_validate_unique_email(opts)
  end

  defp maybe_validate_unique_email(changeset, opts) do
    if Keyword.get(opts, :validate_email, true) do
      changeset
      |> unsafe_validate_unique(:email, Tickex.Repo)
      |> unique_constraint(:email)
    else
      changeset
    end
  end

  @doc """
  A user changeset for changing the email.

  It requires the email to change otherwise an error is added.
  """
  def email_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:email])
    |> validate_email(opts)
    |> case do
      %{changes: %{email: _}} = changeset -> changeset
      %{} = changeset -> add_error(changeset, :email, "did not change")
    end
  end

  @doc """
  Confirms the account by setting `confirmed_at`.
  """
  def confirm_changeset(user) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    change(user, confirmed_at: now)
  end
end
