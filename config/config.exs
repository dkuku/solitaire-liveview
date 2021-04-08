# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :lvsolitaire, LVSolitaireWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "EOucjtl9bIcWtvl66o8x4xUy9WmxldHShk5hTlCo5xq35B1SM4wILV3CxrYzynK7",
  render_errors: [view: LVSolitaireWeb.ErrorView, accepts: ~w(html json)],
  pubsub_server: LVSolitaire.PubSub,
  live_view: [signing_salt: "Qb1iGkRyiIYJAFIgcrO1C118Yv9nWCmFc"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
