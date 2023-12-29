defmodule TickexWeb.EventLive.Index do
  use TickexWeb, :live_view

  alias Tickex.Events
  alias Tickex.Events.Event

  @impl true
  def mount(_params, _session, socket) do
    socket = assign(socket, current_wallet_address: nil)
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
  def handle_event("wallet-connected", params, socket) do
    socket = assign(socket, current_wallet_address: params["public_address"])
    {:noreply, socket}
  end

  @impl true
  def handle_event("wallet-disconnected", params, socket) do
    socket = assign(socket, current_wallet_address: nil)
    {:noreply, socket}
  end
end
