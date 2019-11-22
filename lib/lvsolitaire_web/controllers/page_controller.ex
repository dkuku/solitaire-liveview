defmodule LVSolitaireWeb.PageController do
  use LVSolitaireWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
