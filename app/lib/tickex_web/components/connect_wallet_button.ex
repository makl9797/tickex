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
  def render(assigns) do
    ~H"""
    <button
      class="flex items-center justify-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700"
      phx-click="connect-metamask"
      phx-target={@myself}
    >
      <img src={~p"/images/meta_mask.svg"} alt="MetaMask Logo" class="mr-2 h-6 w-6" /> Connect to Wallet
    </button>
    """
  end

  @impl true
  def handle_event("connect-metamask", _params, socket) do
    {:noreply, push_event(socket, "connect-metamask", %{})}
  end
end
