defmodule SolitaireWeb.PageController do
  use SolitaireWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
