defmodule TickexWeb.TicketLiveTest do
  use TickexWeb.ConnCase

  import Phoenix.LiveViewTest
  import Tickex.EventsFixtures

  @create_attrs %{purchase_date: "2024-01-02T13:25:00Z", redeemed: true}
  @update_attrs %{purchase_date: "2024-01-03T13:25:00Z", redeemed: false}
  @invalid_attrs %{purchase_date: nil, redeemed: false}

  defp create_ticket(_) do
    ticket = ticket_fixture()
    %{ticket: ticket}
  end

  describe "Index" do
    setup [:create_ticket]

    test "lists all tickets", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/tickets")

      assert html =~ "Listing Tickets"
    end

    test "saves new ticket", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/tickets")

      assert index_live |> element("a", "New Ticket") |> render_click() =~
               "New Ticket"

      assert_patch(index_live, ~p"/tickets/new")

      assert index_live
             |> form("#ticket-form", ticket: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#ticket-form", ticket: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/tickets")

      html = render(index_live)
      assert html =~ "Ticket created successfully"
    end

    test "updates ticket in listing", %{conn: conn, ticket: ticket} do
      {:ok, index_live, _html} = live(conn, ~p"/tickets")

      assert index_live |> element("#tickets-#{ticket.id} a", "Edit") |> render_click() =~
               "Edit Ticket"

      assert_patch(index_live, ~p"/tickets/#{ticket}/edit")

      assert index_live
             |> form("#ticket-form", ticket: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#ticket-form", ticket: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/tickets")

      html = render(index_live)
      assert html =~ "Ticket updated successfully"
    end

    test "deletes ticket in listing", %{conn: conn, ticket: ticket} do
      {:ok, index_live, _html} = live(conn, ~p"/tickets")

      assert index_live |> element("#tickets-#{ticket.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#tickets-#{ticket.id}")
    end
  end

  describe "Show" do
    setup [:create_ticket]

    test "displays ticket", %{conn: conn, ticket: ticket} do
      {:ok, _show_live, html} = live(conn, ~p"/tickets/#{ticket}")

      assert html =~ "Show Ticket"
    end

    test "updates ticket within modal", %{conn: conn, ticket: ticket} do
      {:ok, show_live, _html} = live(conn, ~p"/tickets/#{ticket}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Ticket"

      assert_patch(show_live, ~p"/tickets/#{ticket}/show/edit")

      assert show_live
             |> form("#ticket-form", ticket: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#ticket-form", ticket: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/tickets/#{ticket}")

      html = render(show_live)
      assert html =~ "Ticket updated successfully"
    end
  end
end
