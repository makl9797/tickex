defmodule TickexWeb.EventLive.Show do
  use TickexWeb, :live_view

  alias Tickex.Contracts
  alias Tickex.Events
  alias Tickex.Events.Ticket

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:event, Events.get_event!(id))}
  end

  @impl true
  def handle_info({Tickex.Contracts, {:saved_event, event}}, socket) do
    socket =
      socket
      |> assign(:event, event)
      |> put_flash(:info, "Event updated successfully")
      |> push_patch(to: ~p"/events/#{event.id}")

    {:noreply, socket}
  end

  def handle_info({Tickex.Contracts, {:saved_ticket, ticket}}, socket) do
    socket =
      socket
      |> put_flash(
        :info,
        "Ticket with number #{ticket.contract_ticket_id} for #{ticket.purchase_price} MATIC purchased"
      )

    {:noreply, socket}
  end

  @impl true
  def handle_event("failed-" <> _event, params, socket) do
    {:noreply, Contracts.handle_errors(socket, params)}
  end

  def handle_event("buy-ticket", _params, socket) do
    ticket_params = %{
      purchase_price: socket.assigns.event.ticket_price
    }

    socket =
      case Events.validate_ticket(ticket_params) do
        {:ok, ticket} ->
          ticket = %Ticket{
            ticket
            | event: socket.assigns.event,
              buyer: socket.assigns.current_user
          }

          Contracts.buy_ticket(socket, ticket)

        {:error, _} ->
          put_flash(socket, :error, "Ticket purchase failed")
      end

    {:noreply, socket}
  end

  defp is_owner(nil, _event), do: false

  defp is_owner(current_user, event) do
    event.owner.id == current_user.id
  end

  defp page_title(:show), do: "Show Event"
  defp page_title(:edit), do: "Edit Event"
end
