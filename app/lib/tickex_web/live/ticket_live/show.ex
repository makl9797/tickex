defmodule TickexWeb.TicketLive.Show do
  use TickexWeb, :live_view

  alias Tickex.Events

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:ticket, Events.get_ticket!(id))}
  end

  defp page_title(:show), do: "Show Ticket"
  defp page_title(:edit), do: "Edit Ticket"
end