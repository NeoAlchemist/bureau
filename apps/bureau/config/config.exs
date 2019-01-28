# Since configuration is shared in umbrella projects, this file
# should only configure the :bureau application itself
# and only for organization purposes. All other config goes to
# the umbrella root.
use Mix.Config

config :bureau, ecto_repos: [Bureau.Repo]

config :bureau, :admin,
  username: System.get_env("ADMIN_NAME"),
  password: System.get_env("ADMIN_PASS")

import_config "#{Mix.env()}.exs"
