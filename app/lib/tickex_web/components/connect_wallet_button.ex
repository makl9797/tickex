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
          <div class="bg-light text-dark text-sm font-semibold px-4 py-2 rounded-lg">
            <%= short_wallet_address(@current_wallet_address) %>
          </div>
          <div class="relative ml-3">
            <div>
              <button
                phx-click={toggle_dropdown()}
                phx-click-away={close_dropdown()}
                type="button"
                class="relative flex max-w-xs items-center rounded-full bg-gray-800 text-sm focus:outline-none focus:ring-2 focus:ring-brand focus:ring-offset-2 focus:ring-offset-gray-800"
                id="user-menu-button"
                aria-expanded="false"
                aria-haspopup="true"
              >
                <span class="absolute -inset-1.5"></span>
                <span class="sr-only">Open user menu</span>
                <img src={~p"/images/meta_mask.svg"} alt="MetaMask Logo" class="h-8 w-8 rounded-full" />
              </button>
            </div>
            <div
              id="profile-dropdown"
              class="absolute right-0 z-10 mt-2 w-48 origin-top-right rounded-md bg-white py-1 shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none hidden"
              role="menu"
              aria-orientation="vertical"
              aria-labelledby="user-menu-button"
              tabindex="-1"
            >
              <.link
                navigate={~p"/user/tickets"}
                class="block px-4 py-2 text-sm text-dark hover:bg-gray-100"
                role="menuitem"
                tabindex="-1"
                id="user-menu-item-1"
              >
                My Tickets
              </.link>
              <%!-- <.link
                navigate={~p"/user/settings"}
                class="block px-4 py-2 text-sm text-dark  hover:bg-gray-100"
                role="menuitem"
                tabindex="-1"
                id="user-menu-item-2"
              >
                Settings
              </.link> --%>
              <.form for={%{}} action={~p"/logout"} method="delete" as={:user} phx-trigger-action={@logout} class="w-full">
                <button
                  class="block px-4 py-2 text-sm text-dark  hover:bg-gray-100"
                  role="menuitem"
                  tabindex="-1"
                  id="user-menu-item-3"
                >
                  Sign out
                </button>
              </.form>
            </div>
          </div>
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

  defp toggle_dropdown do
    JS.toggle(
      to: "#profile-dropdown",
      in: {"transition ease-out duration-100", "transform opacity-0 scale-95", "transform opacity-100 scale-100"},
      out: {"transition ease-in duration-75", "transform opacity-100 scale-100", "transform opacity-0 scale-95"}
    )
  end

  defp close_dropdown do
    JS.hide(
      to: "#profile-dropdown",
      transition: {"transition ease-in duration-75", "transform opacity-100 scale-100", "transform opacity-0 scale-95"}
    )
  end

  defp short_wallet_address(nil), do: ""

  defp short_wallet_address(address) when is_binary(address) do
    String.slice(address, 0, 7) <> "..." <> String.slice(address, -5..-1)
  end
end
