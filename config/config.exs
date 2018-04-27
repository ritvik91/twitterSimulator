# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :twitterproject,
  ecto_repos: [Twitterproject.Repo]

# Configures the endpoint
config :twitterproject, TwitterprojectWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "bJvG0NkpqkX4GiRm5fPEQtOnYTBca9vr+i8RIMNhb4F4uhUu4KcX6OpZBHxzg+QX",
  render_errors: [view: TwitterprojectWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Twitterproject.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :guardian, Guardian,
  hooks: GuardianDb,
  issuer: "Twitterproject",
  ttl: { 365, :days },
  allowed_drift: 2000,
  secret_key: to_string(Mix.env) <> "js1298#4%jwbu%4nms$#hjknQNnxjknaQNS675b67tbg3872bhs$ab%csbVHFJSD9",
  serializer: Twitterproject.GuardianSerializer

config :guardian_db, GuardianDb,
    repo: Twitterproject.Repo

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

