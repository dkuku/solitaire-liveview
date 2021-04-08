defmodule LVSolitaireWeb.Router do
  use LVSolitaireWeb, :router
  import Phoenix.LiveDashboard.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_root_layout, {LVSolitaireWeb.LayoutView, :root}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", LVSolitaireWeb do
    pipe_through :browser
    live "/", GameLive
    live_dashboard "/dashboard"
  end

  # Other scopes may use custom stacks.
  # scope "/api", LVSolitaireWeb do
  #   pipe_through :api
  # end
end
