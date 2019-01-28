defmodule Bureau.Repo do
  use Ecto.Repo,
    otp_app: :bureau,
    adapter: Ecto.Adapters.Postgres

  use Scrivener, page_size: 10
end
