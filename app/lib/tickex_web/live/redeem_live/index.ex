defmodule TickexWeb.RedeemLive.Index do
  use TickexWeb, :live_view

  alias Tickex.Events
  alias Tickex.Events.Ticket

  @impl true
  def handle_params(%{"id" => id}, _url, socket) do
    event = Events.get_event!(id)
    tickets =
      Events.list_tickets()
      |> Enum.filter(fn ticket -> ticket.event.id == id end)

    socket =
      socket
      |> stream(:tickets, tickets)
      |> assign(:event, event)
      |> assign(:page_title, "Redeem Tickets")
      |> assign(:return, "/events/#{id}/redeem")

    {:noreply, socket}
  end

  @impl true
  def handle_info({TickexWeb.TicketLive.FormComponent, {:saved, ticket}}, socket) do
    {:noreply, stream_insert(socket, :tickets, ticket)}
  end

  defp redeemed(true), do: "Yes"
  defp redeemed(_redeemed), do: "No"
end
