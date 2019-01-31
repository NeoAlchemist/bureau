defmodule Bureau.Offer do
  @behaviour Bureau
 @moduledoc """
 This module deal with job offers. Just simple CRUD action and some `list/1` and `latest/0` function.
 """
  use CRUD, schema: Bureau.JobOffer

  alias Bureau.Query

  @doc """
  params are [remote: boolean, order: :asc | :desc, urgent: boolean, country: String.t]
  """
  @spec list(Keyword.t()) :: list(Ecto.Schema.t()) | Scrivener.Page.t()
  def list(params \\ []) do
    JobOffer
    |> Query.compose(params)
    |> Repo.paginate(params)
  end

  @doc """
  Just give 10 last inserted and verified job offers
  """
  def latest,
    do:
      Query.compose(JobOffer, verified: true, close: false, order: :desc, limit: 10) |> Repo.all()
end
