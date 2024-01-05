defmodule Tickex.Contracts do
  @moduledoc false
  use Tickex.Contracts.EventListener, delay: 1000, max_attempts: 15

  import Phoenix.LiveView

  alias Tickex.Accounts.User
  alias Tickex.Contracts.{EventStorage, TicketStorage}
  alias Tickex.Events.{Event, Ticket}

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
    %Event{
      ticket_price: ticket_price,
      number_of_tickets: tickets_available,
      owner: %User{wallet_address: wallet_address}
    } = event

    filter = EventStorage.EventFilters.event_created(wallet_address)
    subscribe("event_created", filter)

    socket
    |> push_event("create-event", %{
      ticketPrice: ticket_price,
      ticketsAvailable: tickets_available
    })
  end

  def buy_ticket(socket, event) do
    %Event{
      contract_event_id: contract_event_id,
      ticket_price: ticket_price,
      owner: %User{wallet_address: wallet_address}
    } = event

    filter = TicketStorage.EventFilters.ticket_created(nil)
    subscribe("ticket_created", filter)

    socket
    |> push_event("buy-ticket", %{eventId: contract_event_id, ticketPrice: ticket_price})
  end

  def redeem_ticket(socket, ticket) do
    %Ticket{
      contract_ticket_id: contract_ticket_id,
      event: %Event{contract_event_id: contract_event_id}
    } = ticket

    filter = TicketStorage.EventFilters.ticket_redeemed(nil)
    subscribe("ticket_redeemed", filter)

    socket
    |> push_event("redeem-ticket", %{eventId: contract_event_id, ticketNumber: contract_ticket_id})
  end

  @impl EventListener
  def handle_contract_event({:ok, [event]}, "event_created") do
    IO.inspect(event)
    :halt
  end

  def handle_contract_event({:ok, [event]}, "event_updated") do
    IO.inspect(event)
    :halt
  end

  def handle_contract_event({:ok, [event]}, "ticket_redeemed") do
    IO.inspect(event)
    :halt
  end

  def handle_contract_event({:ok, [event]}, "ticket_created") do
    IO.inspect(event)
    :halt
  end

  def handle_contract_event(_response, _event_name), do: IO.inspect(:continue)
end
