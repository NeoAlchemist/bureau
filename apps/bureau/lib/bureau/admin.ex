defmodule Bureau.Admin do
  @moduledoc """
  This module keep all logic and admin account for dashboard
  """
  defmodule Account do
    defstruct username: nil,
              password: nil

    @opaque t() :: %__MODULE__{
              username: String.t(),
              password: String.t()
            }
  end

  alias Bureau.Query
  alias Bureau.Account.Encryption, as: Encrypt

  def authorized(%{"username" => username, "password" => password}) do
    admin = 
      %Account{
        username: Application.get_env(:bureau, :admin)[:username],
        password: Application.get_env(:bureau, :admin)[:password]
    }

    with true <- username == admin.username,
         true <- Encrypt.validate(password, admin.password) do
      {:ok, admin}
    end
  end

  def statistics(type) do
    get_query = fn sch, query -> Query.compose(sch, query) |> Bureau.Repo.one!() end

    total = Task.async(fn -> get_query.(type, count: []) end)
    today = Task.async(fn -> get_query.(type, date: Date.utc_today(), count: []) end)
    verified = Task.async(fn -> get_query.(type, count: [verified: true]) end)

    stats = %{
      total: Task.await(total),
      verified: Task.await(verified),
      today: Task.await(today)
    }

    {:ok, stats}
  end
end
