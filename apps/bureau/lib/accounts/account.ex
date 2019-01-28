defmodule Bureau.Account do
  @behaviour Bureau

  use CRUD, schema: Bureau.User

  alias Bureau.Query

  # can be done with ilike and limit: 1, to find most common username
  # but I think is better to get exacly that one user.
  # Only think to watch out is that this approce is case sensitive!
  def read(username) when is_bitstring(username) do
    User
    |> Query.compose(username: String.replace(username, "_", " "))
    |> Repo.one()
  end

  # if first params is username then search using ilike query and then pass tail to Query.compose
  def list(params), do: Query.compose(User, params) |> Repo.all()

  def latest, do: Query.compose(User, verified: true, order: :desc, limit: 3) |> Repo.all()
end
