defmodule Tickex.Contracts do
  @moduledoc false
  use Tickex.Contracts.EventListener, delay: 1000, max_attempts: 30

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

    filter = EventStorage.EventFilters.event_created(nil, wallet_address)
    subscribe("event_created", filter, event)

    socket
    |> push_event("create-event", %{
      ticketPrice: ticket_price,
      ticketsAvailable: tickets_available
    })
  end

  def update_event(socket, event) do
    %Event{
      contract_event_id: contract_event_id,
      ticket_price: ticket_price,
      number_of_tickets: tickets_available,
      owner: %User{wallet_address: wallet_address}
    } = event

    filter = EventStorage.EventFilters.event_updated(contract_event_id, wallet_address)
    subscribe("event_updated", filter, event)

    socket
    |> push_event("update-event", %{
      newTicketPrice: ticket_price,
      newTicketsAvailable: tickets_available,
      eventId: contract_event_id
    })
  end

  def buy_ticket(socket, event) do
    %Event{
      contract_event_id: contract_event_id,
      ticket_price: ticket_price,
      owner: %User{wallet_address: wallet_address}
    } = event

    filter = TicketStorage.EventFilters.ticket_created(nil, contract_event_id, wallet_address)
    subscribe("ticket_created", filter, event)

    socket
    |> push_event("buy-ticket", %{eventId: contract_event_id, ticketPrice: ticket_price})
  end

  def redeem_ticket(socket, ticket) do
    %Ticket{
      contract_ticket_id: contract_ticket_id,
      event: %Event{contract_event_id: contract_event_id}
    } = ticket

    filter = TicketStorage.EventFilters.ticket_redeemed(contract_ticket_id, nil, nil)
    subscribe("ticket_redeemed", filter, ticket)

    socket
    |> push_event("redeem-ticket", %{eventId: contract_event_id, ticketNumber: contract_ticket_id})
  end

  @impl EventListener
  def handle_contract_event({:ok, [ethers_event]}, "event_created", event) do
    IO.inspect(ethers_event)
    :halt
  end

  def handle_contract_event({:ok, [ethers_event]}, "event_updated", event) do
    IO.inspect(ethers_event)
    :halt
  end

  def handle_contract_event({:ok, [ethers_event]}, "ticket_redeemed", ticket) do
    IO.inspect(ethers_event)
    :halt
  end

  def handle_contract_event({:ok, [ethers_event]}, "ticket_created", ticket) do
    IO.inspect(ethers_event)
    :halt
  end

  def handle_contract_event(_response, _event_name, _item) do
    :continue
  end

  def handle_errors(socket, %{"error" => "user rejected transaction" <> _rest = error}) do
    error_msg =
      error
      |> String.split(",")
      |> List.first()

    put_flash(socket, :error, error_msg)
  end

  def handle_errors(socket, %{"error" => error}) do
    try do
      error_msg =
        error
        |> String.split("reverted:")
        |> List.last()
        |> String.split("\"")
        |> List.first()

      put_flash(socket, :error, error_msg)
    catch
      _ -> handle_errors(socket, %{"error" => "Unknown Error"})
    end
  end

  def handle_errors(socket, _params), do: put_flash(socket, :error, "Unknown Error")
end
