defmodule Bureau do
  @moduledoc """
  With introduction of context in Phoenix 1.3 
  ElixirConf: https://www.youtube.com/watch?v=tMO28ar0lW8

  Best practice to use phoenix app as web interface and moving business logic into
  separate app.
  
  Also using Elixir Behaviour you could follow some of SOLID principles.
  More here: https://medium.com/@andreichernykh/solid-elixir-777584a9ccba
  
  As this app need to deal with normal database action like read create update and delete (CRUD)
  And for now we have two context where this action will apply: Account and JobOffer.
  We can just use behaviour to make app more extendable.
  """
  @type schema :: Ecto.Schema.t()
  @type changeset :: Ecto.Changeset.t()

  @callback create(map | Keyword.t()) :: {:ok, schema} | {:error, changeset}

  @callback read(integer | Keyword.t()) :: schema | nil

  @callback update(schema | changeset, map | Keyword.t()) :: {:ok, schema} | {:error, changeset}

  @callback delete(schema | changeset) :: {:ok, schema} | {:error, changeset}

  @callback list(Keyword.t()) :: list(schema) | Scrivener.Page.t()

  @callback latest() :: list(schema)

  @optional_callbacks latest: 0
end
