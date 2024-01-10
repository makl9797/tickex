defmodule TickexWeb.EventLive.Index do
  use TickexWeb, :live_view

  alias Tickex.Contracts
  alias Tickex.Events
  alias Tickex.Events.Event

  @impl true
  def mount(_params, _session, socket) do
    events = Events.list_events() |> Enum.sort(fn ticket1, ticket2 -> ticket1.updated_at > ticket2.updated_at end)

    user_events =
      if socket.assigns.current_user do
        events
        |> Enum.filter(fn event -> event.owner.id == socket.assigns.current_user.id end)
      else
        []
      end

    socket =
      socket
      |> stream(:events, events)
      |> stream(:user_events, user_events)

    {:ok, socket}
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
    |> assign(:event, %Event{owner: socket.assigns.current_user})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "All Events")
    |> assign(:event, nil)
  end

  @impl true
  def handle_info({Contracts, {:saved_event, event}}, socket) do
    socket =
      socket
      |> stream_insert(:events, event)
      |> put_flash(:info, "Event created successfully")
      |> push_patch(to: ~p"/events")

    {:noreply, socket}
  end

  @impl true
  def handle_event("failed-" <> _event, params, socket) do
    {:noreply, Contracts.handle_errors(socket, params)}
  end
end
