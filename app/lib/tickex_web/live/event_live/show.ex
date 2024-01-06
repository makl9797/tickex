defmodule TickexWeb.EventLive.Show do
  use TickexWeb, :live_view

  alias Tickex.Contracts
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
     |> assign(:event, Events.get_event!(id))}
  end

  @impl true
  def handle_info({Tickex.Contracts, {:saved, event}}, socket) do
    socket =
      socket
      |> assign(:event, event)
      |> put_flash(:info, "Event updated successfully")
      |> push_patch(to: ~p"/events/#{event.id}")

    {:noreply, socket}
  end

  @impl true
  def handle_event("failed-" <> _event, params, socket) do
    {:noreply, Contracts.handle_errors(socket, params)}
  end

  defp is_owner(nil, _event), do: false

  defp is_owner(current_user, event) do
    event.owner.id == current_user.id
  end

  defp page_title(:show), do: "Show Event"
  defp page_title(:edit), do: "Edit Event"
end
