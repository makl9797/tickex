defmodule TickexWeb.RedeemLive.Index do
  use TickexWeb, :live_view

  alias Tickex.Contracts
  alias Tickex.Events

  @impl true
  def handle_params(%{"id" => id}, _url, socket) do
    event = Events.get_event!(id)

    tickets =
      Events.list_tickets()
      |> Enum.filter(fn ticket -> ticket.event.id == id end)
      |> Enum.sort(fn ticket1, ticket2 -> ticket1.updated_at > ticket2.updated_at end)

    socket =
      socket
      |> stream(:tickets, tickets)
      |> assign(:event, event)
      |> assign(:page_title, "Redeem Tickets")
      |> assign(:return, "/events/#{id}/redeem")

    {:noreply, socket}
  end

  @impl true
  def handle_info({Contracts, {:saved_ticket, ticket}}, socket) do
    socket =
      socket
      |> put_flash(:info, "Ticket ##{ticket.contract_ticket_id} redeemed.")
      |> stream_insert(:tickets, ticket)

    {:noreply, socket}
  end

  def handle_event("redeem-ticket", %{"ticket_id" => ticket_id}, socket) do
    ticket = Events.get_ticket!(ticket_id)

    {:noreply, Contracts.redeem_ticket(socket, ticket)}
  end

  @impl true
  def handle_event("failed-" <> _event, params, socket) do
    {:noreply, Contracts.handle_errors(socket, params)}
  end
end
