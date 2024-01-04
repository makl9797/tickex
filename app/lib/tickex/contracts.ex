defmodule Tickex.Contracts do
  @moduledoc false

  import Phoenix.LiveView

  alias Tickex.Contracts.{EventStorage, TicketStorage}
  alias Tickex.Events.Event

  def get_event(event_id) do
    event_id
    |> EventStorage.get_event_object()
    |> Ethers.call()
  end

  def get_ticket(event_id, ticket_id) do
    TicketStorage.get_ticket(event_id, ticket_id) |> Ethers.call()
  end

  def get_ticket_count_for_event(event_id) do
    event_id
    |> TicketStorage.get_ticket_count_for_event()
    |> Ethers.call()
  end

  def create_event(socket, event) do
    %Event{ticket_price: ticket_price, number_of_tickets: tickets_available} = event
    start_event_listener(EventStorage.EventFilters.event_created(nil), &event_created/1)

    socket
    |> push_event("create-event", %{
      ticketPrice: ticket_price,
      ticketsAvailable: tickets_available
    })
  end

  defp event_created({:ok, []}), do: :continue

  defp event_created({:ok, [event]}) do
    IO.inspect(event)
    :halt
  end

  def start_event_listener(filter_fun, handle_fun) do
    Task.start(fn -> listen_for_event(filter_fun, handle_fun) end)
  end

  defp listen_for_event(:continue, filter_fun, handle_fun) do
    :timer.sleep(1000)
    listen_for_event(filter_fun, handle_fun)
  end

  defp listen_for_event(:halt, _filter_fun, _handle_fun), do: :ok

  defp listen_for_event(filter_fun, handle_fun) do
    filter_fun
    |> Ethers.get_logs()
    |> handle_fun.()
    |> listen_for_event(filter_fun, handle_fun)
  end
end
