defmodule Tickex.EventsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Tickex.Events` context.
  """

  @doc """
  Generate a ticket.
  """
  def ticket_fixture(attrs \\ %{}) do
    {:ok, ticket} =
      attrs
      |> Enum.into(%{
        purchase_date: ~U[2024-01-02 13:25:00Z],
        redeemed: true
      })
      |> Tickex.Events.create_ticket()

    ticket
  end
end
