defmodule TickexWeb.TicketLive.Index do
  use TickexWeb, :live_view

  alias Tickex.Events
  alias Tickex.Events.Ticket

  @impl true
  def mount(_params, _session, socket) do
    user_tickets =
      Events.list_tickets()
      |> Enum.filter(fn ticket -> ticket.buyer.id == socket.assigns.current_user.id end)

    {:ok, stream(socket, :tickets, user_tickets)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Ticket")
    |> assign(:ticket, Events.get_ticket!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Ticket")
    |> assign(:ticket, %Ticket{})
  end

  defp apply_action(socket, :user_index, _params) do
    socket
    |> assign(:page_title, "Listing Tickets")
    |> assign(:ticket, nil)
  end

  @impl true
  def handle_info({TickexWeb.TicketLive.FormComponent, {:saved, ticket}}, socket) do
    {:noreply, stream_insert(socket, :tickets, ticket)}
  end
end
