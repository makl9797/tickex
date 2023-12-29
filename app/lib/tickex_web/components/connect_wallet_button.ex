defmodule TickexWeb.Components.ConnectWalletButton do
  use TickexWeb, :live_component

  @impl true
  def mount(socket) do
    socket =
      assign(
        socket,
        connected: false,
        current_wallet_address: nil,
        signature: nil,
        verify_signature: false
      )

    {:ok, socket}
  end

  @impl true
  def update(assigns, socket) do
    socket =
      assign(socket,
        connected: !is_nil(assigns.current_wallet_address),
        current_wallet_address: assigns.current_wallet_address
      )

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div id="metamask-button" phx-hook="Metamask">
      <div :if={@connected} class="flex items-center space-x-4">
        <div class="bg-blue-100 text-blue-800 text-sm font-semibold px-4 py-2 rounded-lg">
          <%= short_wallet_address(@current_wallet_address) %>
        </div>

        <button phx-click="logout" class="bg-red-500 hover:bg-red-600 text-white font-bold py-2 px-4 rounded">
          Logout
        </button>
      </div>
      <button
        :if={!@connected}
        class="flex items-center justify-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700"
        phx-click="connect-metamask"
        phx-target={@myself}
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

  defp short_wallet_address(nil), do: ""

  defp short_wallet_address(address) when is_binary(address) do
    String.slice(address, 0, 7) <> "..." <> String.slice(address, -5..-1)
  end
end