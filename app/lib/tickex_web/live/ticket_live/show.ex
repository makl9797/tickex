defmodule TickexWeb.TicketLive.Show do
  use TickexWeb, :live_view

  alias Tickex.Events

  @impl true
  def handle_params(%{"id" => id} = params, url, socket) do
    socket =
      socket
      |> assign(:page_title, "Show Ticket")
      |> assign(:ticket, Events.get_ticket!(id))
      |> assign(:return, params["return"])

    {:noreply, socket}
  end
end
