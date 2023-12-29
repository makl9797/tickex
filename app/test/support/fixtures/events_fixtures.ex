defmodule Tickex.EventsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Tickex.Events` context.
  """

  @doc """
  Generate a event.
  """
  def event_fixture(attrs \\ %{}) do
    {:ok, event} =
      attrs
      |> Enum.into(%{
        creation_date: ~U[2023-12-27 17:38:00Z],
        description: "some description",
        location: "some location",
        title: "some title"
      })
      |> Tickex.Events.create_event()

    event
  end
end
