defmodule Tickex.Contracts do
  @moduledoc false

  alias Tickex.Contracts.{EventStorage, TicketStorage}

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
end
