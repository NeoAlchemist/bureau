defmodule Bureau do
  @moduledoc """
  Bureau keeps the contexts that define your domain
  and business logic.

  Also it is public API
  """
  @type schema :: Ecto.Schema.t()
  @type changeset :: Ecto.Changeset.t()

  @callback create(map | Keyword.t()) :: {:ok, schema} | {:error, changeset}

  @callback read(any) :: schema | nil

  @callback update(schema | changeset, map | Keyword.t()) :: {:ok, schema} | {:error, changeset}

  @callback delete(schema | changeset) :: {:ok, schema} | {:error, changeset}

  @callback list(Keyword.t()) :: list(schema) | Scrivener.Page.t()

  @callback latest() :: list(schema)

  @optional_callbacks latest: 0
end
