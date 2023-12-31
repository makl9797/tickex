defmodule TickexWeb.Components.ConnectWalletButton do
  use TickexWeb, :live_view

  alias Tickex.Accounts
  alias Tickex.Accounts.User

  on_mount({TickexWeb.UserAuth, :mount_current_user})

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign_current_user()
      |> assign(
        signature: nil,
        verify_signature: false,
        logout: false
      )

    {:ok, socket}
  end

  defp assign_current_user(%{assigns: %{current_user: %User{} = current_user}} = socket) do
    assign(socket,
      connected: true,
      current_wallet_address: current_user.wallet_address,
      logged_in: true
    )
  end

  defp assign_current_user(socket) do
    assign(
      socket,
      connected: false,
      current_wallet_address: nil,
      logged_in: false
    )
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div id="metamask-button" phx-hook="Metamask">
      <div :if={@connected}>
        <.form for={%{}} action={~p"/auth"} as={:user} phx-submit="verify-signature" phx-trigger-action={@verify_signature}>
          <.input type="hidden" name="public_address" value={@current_wallet_address} />
          <.input type="hidden" name="signature" value={@signature} />
        </.form>
        <div :if={@logged_in} class="flex items-center space-x-4">
        <div class="bg-blue-100 text-blue-800 text-sm font-semibold px-4 py-2 rounded-lg">
          <%= short_wallet_address(@current_wallet_address) %>
        </div>
        <.form
          for={%{}}
          action={~p"/logout"}
          method="delete"
          as={:user}
          phx-trigger-action={@logout}
        >
          <button type="submit" class="bg-red-500 hover:bg-red-600 text-white font-bold py-2 px-4 rounded">
            Logout
          </button>
        </.form>
        </div>
      </div>
      <button
        :if={!@connected}
        class="flex items-center justify-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700"
        phx-click="connect-metamask"
      >
        <img src={~p"/images/meta_mask.svg"} alt="MetaMask Logo" class="mr-2 h-6 w-6" /> Connect to Wallet
      </button>
    </div>
    """
  end

  @impl true
  def handle_event("connect-metamask", _params, socket) do
    {:noreply, push_event(socket, "connect-metamask", %{})}
  end

  @impl true
  def handle_event("metamask-connected", params, socket) do
    %{"public_address" => wallet_address} = params

    nonce =
      case Accounts.get_user_by_wallet_address(wallet_address) do
        nil -> Accounts.generate_account_nonce()
        user -> user.nonce
      end

    socket =
      socket
      |> assign(
        current_wallet_address: wallet_address,
        nonce: nonce,
        logout: false
      )
      |> push_event("verify-wallet", %{nonce: nonce})

    {:noreply, socket}
  end

  @impl true
  def handle_event("verify-signature", %{"signature" => signature}, socket) do
    %{current_wallet_address: wallet_address, nonce: nonce} = socket.assigns

    Accounts.register_user(%{wallet_address: wallet_address, nonce: nonce})

    socket =
      assign(socket,
        connected: true,
        signature: signature,
        verify_signature: true,
        nonce: nil,
        logged_in: true
      )

    {:noreply, socket}
  end

  @impl true
  def handle_event("signature-failed", _params, socket) do
    socket =
      assign(socket,
        connected: false,
        current_wallet_address: nil,
        logged_in: false
      )

    {:noreply, socket}
  end

  @impl true
  def handle_event("metamask-disconnected", _params, socket) do
    socket =
      socket
      |> assign(logout: true, logged_in: false)

    {:noreply, socket}
  end

  defp short_wallet_address(nil), do: ""

  defp short_wallet_address(address) when is_binary(address) do
    String.slice(address, 0, 7) <> "..." <> String.slice(address, -5..-1)
  end
end
