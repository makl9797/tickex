defmodule TickexWeb.EventLive.Index do
  use TickexWeb, :live_view

  alias Tickex.Accounts.User
  alias Tickex.Contracts
  alias Tickex.Events
  alias Tickex.Events.{Event, Ticket}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :events, Events.list_events())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Event")
    |> assign(:event, %Event{owner: socket.assigns.current_user})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Events")
    |> assign(:event, nil)
  end

  @impl true
  def handle_info({Tickex.Contracts, {:saved, event}}, socket) do
    socket =
      socket
      |> stream_insert(:events, event)
      |> put_flash(:info, "Event created successfully")

    {:noreply, socket}
  end

  @impl true
  def handle_event("failed-" <> event, params, socket) do
    {:noreply, Contracts.handle_errors(socket, params)}
  end
end
