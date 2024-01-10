defmodule Tickex.EventsTest do
  use Tickex.DataCase

  alias Tickex.Events

  describe "events" do
    alias Tickex.Events.Event

    import Tickex.EventsFixtures

    @invalid_attrs %{description: nil, title: nil, location: nil, creation_date: nil}

    test "list_events/0 returns all events" do
      event = event_fixture()
      assert Events.list_events() == [event]
    end

    test "get_event!/1 returns the event with given id" do
      event = event_fixture()
      assert Events.get_event!(event.id) == event
    end

    test "create_event/1 with valid data creates a event" do
      valid_attrs = %{
        description: "some description",
        title: "some title",
        location: "some location",
        creation_date: ~U[2023-12-27 17:38:00Z]
      }

      assert {:ok, %Event{} = event} = Events.create_event(valid_attrs)
      assert event.description == "some description"
      assert event.title == "some title"
      assert event.location == "some location"
      assert event.creation_date == ~U[2023-12-27 17:38:00Z]
    end

    test "create_event/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Events.create_event(@invalid_attrs)
    end

    test "update_event/2 with valid data updates the event" do
      event = event_fixture()

      update_attrs = %{
        description: "some updated description",
        title: "some updated title",
        location: "some updated location",
        creation_date: ~U[2023-12-28 17:38:00Z]
      }

      assert {:ok, %Event{} = event} = Events.update_event(event, update_attrs)
      assert event.description == "some updated description"
      assert event.title == "some updated title"
      assert event.location == "some updated location"
      assert event.creation_date == ~U[2023-12-28 17:38:00Z]
    end

    test "update_event/2 with invalid data returns error changeset" do
      event = event_fixture()
      assert {:error, %Ecto.Changeset{}} = Events.update_event(event, @invalid_attrs)
      assert event == Events.get_event!(event.id)
    end

    test "delete_event/1 deletes the event" do
      event = event_fixture()
      assert {:ok, %Event{}} = Events.delete_event(event)
      assert_raise Ecto.NoResultsError, fn -> Events.get_event!(event.id) end
    end

    test "change_event/1 returns a event changeset" do
      event = event_fixture()
      assert %Ecto.Changeset{} = Events.change_event(event)
    end
  end
end
