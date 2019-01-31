defmodule Bureau.Account do
  @behaviour Bureau
  @moduledoc """
  This module deal with user schema, even if the best way is to split
  user into two different schemas. An access schema with just email and password
  and Profile schema. 
  But to make it easy and fast I used just one user schema.
  If you want to know more of design patterns for Elixir app you can read this guide:
  https://github.com/danielberkompas/mithril/tree/master/guides
  """

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

  @doc """
  params are [username: String.t, remote: boolean, order: :asc | :desc, urgent: boolean, country: String.t]
  """
  def list(params), do: Query.compose(User, params) |> Repo.all()

  @doc """
  Just give 3 last inserted and verified users
  """
  def latest, do: Query.compose(User, verified: true, order: :desc, limit: 3) |> Repo.all()
end
