defmodule BureauWeb.SearchJob do
  use Ecto.Schema
  import Ecto.Changeset
  alias Bureau.Offer

  schema "" do
    field(:remote, :boolean, virtual: true)
    field(:urgent, :boolean, virtual: true)
    field(:country, :string, virtual: true)
    field(:order, :string, virtual: true)
    field(:page, :string, virtual: true)

    # put the result of search in this map
    field(:result, :map, virtual: true)
  end

  @params ~w(remote urgent country order page)a

  def changeset(attrs \\ %{}) do
    %__MODULE__{}
    |> cast(attrs, @params)
    |> validate_format(:country, ~r/^[a-zA-Z()& ]+$/)
    |> validate_format(:page, ~r/^[0-9]+$/)
    |> validate_length(:page, min: 1)
    |> remove_false_params()
    |> transform_order_to_atom()
    |> get_jobs_list()
  end

  # removes from changese all false key in this way I don't have problems with pagination
  defp remove_false_params(changeset = %Ecto.Changeset{valid?: true, changes: params}) do
    changes_no_false =
      Enum.reduce(params, params, fn
        {key, false}, acc -> Map.delete(acc, key)
        {_, _}, acc -> acc
      end)

    %{changeset | changes: changes_no_false}
  end

  defp transform_order_to_atom(
         changeset = %Ecto.Changeset{valid?: true, changes: %{order: order}}
       ) do
    order
    |> case do
      "Ascending" ->
        changeset
        |> put_change(:order, :asc)

      "Descending" ->
        changeset
        |> put_change(:order, :desc)

      _ ->
        changeset
    end
  end

  defp transform_order_to_atom(changeset), do: changeset

  defp get_jobs_list(changeset = %Ecto.Changeset{valid?: true, changes: params}) do
    list = Map.to_list(params) |> Offer.list()

    changeset
    |> put_change(:result, list)
  end

  defp get_jobs_list(changeset) do
    changeset
    |> put_change(:result, Offer.list())
  end
end
