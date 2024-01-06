defmodule TickexWeb.EventLive.FormComponent do
  use TickexWeb, :live_component

  alias Tickex.Contracts
  alias Tickex.Events
  alias Tickex.Events.Event

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to create a new event.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="event-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
        phx-hook="Contracts"
      >
        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:description]} type="textarea" label="Description" />
        <.input field={@form[:location]} type="text" label="Location" />
        <.input field={@form[:ticket_price]} type="number" step="0.01" label="Ticket Price" />
        <.input field={@form[:number_of_tickets]} type="number" label="Number of Tickets" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Event</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{event: event} = assigns, socket) do
    changeset = Events.change_event(event)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"event" => event_params}, socket) do
    changeset =
      socket.assigns.event
      |> Events.change_event(event_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"event" => event_params}, socket) do
    save_event(socket, socket.assigns.action, event_params)
  end

  defp save_event(socket, :edit, event_params) do
    socket =
      case Events.validate_event(socket.assigns.event, event_params) do
        {:ok, %Event{has_on_chain_changes: true} = event} ->
          socket
          |> Contracts.update_event(event)

        {:ok, %Event{} = event} ->
          Events.update_event(socket.assigns.event, event_params)

          socket
          |> put_flash(:info, "Event updated successfully")
          |> push_patch(to: socket.assigns.patch)

        {:error, %Ecto.Changeset{} = changeset} ->
          assign_form(socket, changeset)
      end

    {:noreply, socket}
  end

  defp save_event(socket, :new, event_params) do
    case Events.validate_event(socket.assigns.event, event_params) do
      {:ok, event} ->
        socket =
          socket
          |> Contracts.create_event(event)

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
