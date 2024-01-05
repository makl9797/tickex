defmodule TickexWeb.EventLive.Index do
  use TickexWeb, :live_view

  alias Tickex.Accounts.User
  alias Tickex.Contracts
  alias Tickex.Events
  alias Tickex.Events.Event

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :events, Events.list_events())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Event")
    |> assign(:event, Events.get_event!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Event")
    |> assign(:event, %Event{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Events")
    |> assign(:event, nil)
  end

  @impl true
  def handle_info({TickexWeb.EventLive.FormComponent, {:saved, event}}, socket) do
    {:noreply, stream_insert(socket, :events, event)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    event = Events.get_event!(id)
    {:ok, _} = Events.delete_event(event)

    {:noreply, stream_delete(socket, :events, event)}
  end

  @impl true
  def handle_event("create-event", _params, socket) do
    event = %Event{
      ticket_price: 0.1,
      number_of_tickets: 100,
      owner: %User{wallet_address: "0x4ad65758D26201B85c179a5f67005905800030EA"}
    }

    socket =
      socket
      |> Contracts.create_event(event)

    {:noreply, socket}
  end
end
