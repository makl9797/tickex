defmodule Tickex.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Tickex.Repo

  alias Tickex.Accounts.{User, UserToken}

  ## Database getters

  @doc """
  Gets a user by email.

  ## Examples

      iex> get_user_by_email("foo@example.com")
      %User{}

      iex> get_user_by_email("unknown@example.com")
      nil

  """
  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: email)
  end

  @doc """
  Gets a user by their Ethereum wallet address.

  This function looks up a user in the database using the provided Ethereum wallet address. It returns the user struct if a user with the given wallet address is found, or `nil` if no user is associated with that address.

  ## Examples

      iex> get_user_by_wallet_address("0x1234abcd...")
      %User{}

      iex> get_user_by_wallet_address("0xunknown...")
      nil

  """
  def get_user_by_wallet_address(nil), do: nil

  def get_user_by_wallet_address(wallet_address) when is_binary(wallet_address) do
    Repo.get_by(User, wallet_address: wallet_address)
  end

  @doc """
  Generates a unique nonce for account operations.

  This function creates a cryptographically secure random nonce, which can be used for various account-related operations where uniqueness is crucial. The nonce is generated as a sequence of random bytes, which is then encoded into a hexadecimal string.

  The generated nonce is typically used in scenarios like authentication processes, to ensure that each operation is unique and to prevent replay attacks.

  It's important to note that the nonce is encoded in hexadecimal format and its length depends on the number of random bytes generated.

  ## Examples

      iex> generate_account_nonce()
      "9F85D9F6C8A3B2A7E7"

  """
  def generate_account_nonce do
    :crypto.strong_rand_bytes(10)
    |> Base.encode16()
  end

  @doc """
  Updates the nonce for a user identified by their Ethereum wallet address.

  This function retrieves the user associated with the given Ethereum address from the database. It then generates a new nonce and updates the user's record with this new nonce. The nonce is a unique, randomly generated string used to ensure the security and uniqueness of each authentication request.

  ## Examples

      iex> update_user_nonce("0x1234abcd...")
      {:ok, %User{nonce: "NewNonce"}}

      iex> update_user_nonce("0xnonexistent...")
      nil

  The function is crucial in authentication scenarios where the integrity of each request is paramount, particularly in systems that use Ethereum wallets for user authentication.

  """
  def update_user_nonce(wallet_address) do
    user = get_user_by_wallet_address(wallet_address)

    attrs = %{
      "wallet_address" => wallet_address,
      "nonce" => generate_account_nonce()
    }

    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Verifies the signature of a message signed by a user's Ethereum wallet.

  This function takes an Ethereum address and a signature and verifies whether the signature is valid for a predefined message concatenated with the user's nonce. It is used to authenticate users based on their Ethereum wallet in a secure manner.

  ## Examples

      iex> verify_message_signature("0x1234abcd...", "0xSignature...")
      %User{}

      iex> verify_message_signature("0x1234abcd...", "0xInvalidSignature...")
      nil
  """
  def verify_message_signature(wallet_address, signature) do
    with user = %User{} <- get_user_by_wallet_address(wallet_address) do
      message = "You are signing this message to sign in with Dora. Nonce: #{user.nonce}"

      signing_address = ExWeb3EcRecover.recover_personal_signature(message, signature)

      if String.downcase(signing_address) == String.downcase(wallet_address) do
        update_user_nonce(wallet_address)
        user
      end
    end
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  ## User registration

  @doc """
  Registers a user.

  ## Examples

      iex> register_user(%{field: value})
      {:ok, %User{}}

      iex> register_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user_registration(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_registration(%User{} = user, attrs \\ %{}) do
    User.registration_changeset(user, attrs, validate_email: false)
  end

  ## Settings

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user email.

  ## Examples

      iex> change_user_email(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_email(user, attrs \\ %{}) do
    User.email_changeset(user, attrs, validate_email: false)
  end

  @doc """
  Emulates that the email will change without actually changing
  it in the database.

  ## Examples

      iex> apply_user_email(user, %{email: ...})
      {:ok, %User{}}

      iex> apply_user_email(user, %{email: ...})
      {:error, %Ecto.Changeset{}}

  """
  def apply_user_email(user, attrs) do
    user
    |> User.email_changeset(attrs)
    |> Ecto.Changeset.apply_action(:update)
  end

  @doc """
  Updates the user email using the given token.

  If the token matches, the user email is updated and the token is deleted.
  The confirmed_at date is also updated to the current time.
  """
  def update_user_email(user, token) do
    context = "change:#{user.email}"

    with {:ok, query} <- UserToken.verify_change_email_token_query(token, context),
         %UserToken{sent_to: email} <- Repo.one(query),
         {:ok, _} <- Repo.transaction(user_email_multi(user, email, context)) do
      :ok
    else
      _ -> :error
    end
  end

  defp user_email_multi(user, email, context) do
    changeset =
      user
      |> User.email_changeset(%{email: email})
      |> User.confirm_changeset()

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, changeset)
    |> Ecto.Multi.delete_all(:tokens, UserToken.by_user_and_contexts_query(user, [context]))
  end

  @doc ~S"""
  Delivers the update email instructions to the given user.

  ## Examples

      iex> deliver_user_update_email_instructions(user, current_email, &url(~p"/users/settings/confirm_email/#{&1})")
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_user_update_email_instructions(%User{} = user, current_email, update_email_url_fun)
      when is_function(update_email_url_fun, 1) do
    {_encoded_token, user_token} = UserToken.build_email_token(user, "change:#{current_email}")

    Repo.insert!(user_token)
  end

  ## Session

  @doc """
  Generates a session token.
  """
  def generate_user_session_token(user) do
    {token, user_token} = UserToken.build_session_token(user)
    Repo.insert!(user_token)
    token
  end

  @doc """
  Gets the user with the given signed token.
  """
  def get_user_by_session_token(token) do
    {:ok, query} = UserToken.verify_session_token_query(token)
    Repo.one(query)
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_user_session_token(token) do
    Repo.delete_all(UserToken.by_token_and_context_query(token, "session"))
    :ok
  end
end
