defmodule TickexWeb.PageController do
  use TickexWeb, :controller

  def home(conn, _params) do
    redirect(conn, to: ~p"/events")
  end
end
