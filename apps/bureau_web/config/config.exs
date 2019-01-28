# Since configuration is shared in umbrella projects, this file
# should only configure the :bureau_web application itself
# and only for organization purposes. All other config goes to
# the umbrella root.
use Mix.Config

# General application configuration
config :bureau_web,
  ecto_repos: [Bureau.Repo],
  generators: [context_app: :bureau]

# Configures the endpoint
config :bureau_web, BureauWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "aEVvZo5e99XRGFT9WhS9QzfB7CcPuRKTTjhDpZeDIYLDZgfGn9b0MRmf/O2Ms8Ey",
  render_errors: [view: BureauWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: BureauWeb.PubSub, adapter: Phoenix.PubSub.PG2]

config :bureau_web, BureauWeb.Guardian,
  issuer: "bureau",
  secret_key: "cey2ZNu/j81MSbLXC7DdxM1llG49wWeVGTL0swOUZffoFaBRG7x6VMIwCm5oiCu8"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
