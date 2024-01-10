defmodule TickexWeb.UserSessionController do
  use TickexWeb, :controller

  alias Tickex.Accounts
  alias TickexWeb.UserAuth

  def create(conn, %{"_action" => "registered"} = params) do
    create(conn, params, "Account created successfully!")
  end

  def create(conn, params) do
    create(conn, params, "Welcome back!")
  end

  defp create(conn, params, info) do
    %{"public_address" => wallet_address, "signature" => signature} = params
    user = Accounts.verify_message_signature(wallet_address, signature)

    if user do
      conn
      |> put_flash(:info, info)
      |> UserAuth.log_in_user(user, params)
    else
      conn
      |> put_flash(:error, "Invalid wallet")
      |> redirect(to: ~p"/")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end
end
