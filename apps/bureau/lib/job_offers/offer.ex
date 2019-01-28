defmodule Bureau.Offer do
  @behaviour Bureau

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

  def latest,
    do:
      Query.compose(JobOffer, verified: true, close: false, order: :desc, limit: 10) |> Repo.all()
end
