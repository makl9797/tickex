defmodule Tickex.EventsTest do
  use Tickex.DataCase

  alias Tickex.Events

  describe "tickets" do
    alias Tickex.Events.Ticket

    import Tickex.EventsFixtures

    @invalid_attrs %{purchase_date: nil, redeemed: nil}

    test "list_tickets/0 returns all tickets" do
      ticket = ticket_fixture()
      assert Tickets.list_tickets() == [ticket]
    end

    test "get_ticket!/1 returns the ticket with given id" do
      ticket = ticket_fixture()
      assert Tickets.get_ticket!(ticket.id) == ticket
    end

    test "create_ticket/1 with valid data creates a ticket" do
      valid_attrs = %{purchase_date: ~U[2024-01-02 13:25:00Z], redeemed: true}

      assert {:ok, %Ticket{} = ticket} = Tickets.create_ticket(valid_attrs)
      assert ticket.purchase_date == ~U[2024-01-02 13:25:00Z]
      assert ticket.redeemed == true
    end

    test "create_ticket/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tickets.create_ticket(@invalid_attrs)
    end

    test "update_ticket/2 with valid data updates the ticket" do
      ticket = ticket_fixture()
      update_attrs = %{purchase_date: ~U[2024-01-03 13:25:00Z], redeemed: false}

      assert {:ok, %Ticket{} = ticket} = Tickets.update_ticket(ticket, update_attrs)
      assert ticket.purchase_date == ~U[2024-01-03 13:25:00Z]
      assert ticket.redeemed == false
    end

    test "update_ticket/2 with invalid data returns error changeset" do
      ticket = ticket_fixture()
      assert {:error, %Ecto.Changeset{}} = Tickets.update_ticket(ticket, @invalid_attrs)
      assert ticket == Tickets.get_ticket!(ticket.id)
    end

    test "delete_ticket/1 deletes the ticket" do
      ticket = ticket_fixture()
      assert {:ok, %Ticket{}} = Tickets.delete_ticket(ticket)
      assert_raise Ecto.NoResultsError, fn -> Tickets.get_ticket!(ticket.id) end
    end

    test "change_ticket/1 returns a ticket changeset" do
      ticket = ticket_fixture()
      assert %Ecto.Changeset{} = Tickets.change_ticket(ticket)
    end
  end
end
