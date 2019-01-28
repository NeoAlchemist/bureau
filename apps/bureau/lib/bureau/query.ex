defmodule Bureau.Query do
  import Ecto.Query

  @doc """
  Compose query using keyword list.

  order of keyword is very important, select need to be last as in normal query.
  Also you can not use select and count together.
  """
  @spec compose(Ecto.Schema.t() | Ecto.Query.t(), Keyword.t()) :: Ecto.Query.t()
  def compose(schema, []), do: schema

  def compose(schema, params) when is_list(params) do
    Enum.reduce(params, from(q in schema), fn attrs, acc -> to_query(attrs, acc) end)
  end

  def compose(schema, _), do: schema

  # skip the page atom
  defp to_query({:page, _}, acc), do: acc

  defp to_query({:count, []}, acc), do: from(q in acc, select: count(q.id))

  defp to_query({:count, list}, acc) when is_list(list) do
    query = compose(acc, list)
    from q in query, select: count(q.id)
  end

  defp to_query({:order, value}, acc) when value == :asc or value == :desc do
    from q in acc, order_by: [{^value, :id}]
  end

  # not the best way.. but for now "OK"
  defp to_query({:like, {:username, name}}, acc),
    do: from(q in acc, where: ilike(q.username, ^"%#{name}%"))

  defp to_query({:like, {:company_name, name}}, acc),
    do: from(q in acc, where: ilike(q.company_name, ^"%#{name}%"))

  defp to_query({:like, _}, acc), do: acc

  defp to_query({:date, date}, acc),
    do: from(q in acc, where: fragment("?::date", q.inserted_at) == ^date)

  defp to_query({:limit, value}, acc) when is_integer(value), do: from(q in acc, limit: ^value)

  defp to_query({:select, list}, acc) when is_list(list), do: from(q in acc, select: ^list)

  defp to_query(params, acc) when is_tuple(params), do: from(q in acc, where: ^[params])

  defp to_query(_, acc), do: acc
end
