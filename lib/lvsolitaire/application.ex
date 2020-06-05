defmodule LVSolitaire.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      LVSolitaireWeb.Endpoint,
      {Phoenix.PubSub, [name: LVSolitaire.PubSub, adapter: Phoenix.PubSub.PG2]}
    ]

    opts = [strategy: :one_for_one, name: LVSolitaire.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    LVSolitaireWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
