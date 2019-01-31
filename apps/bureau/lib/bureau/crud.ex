defmodule CRUD do
  @moduledoc """
  Implementation of CRUD functions. 
  In order to use them just add:
  `use CRUD, schema: SomeEctoSchema`
  """
  @spec __using__(list({atom, Ecto.Schema.t()})) :: any
  defmacro __using__(schema: schema) do
    quote do
      alias Bureau.Repo
      alias unquote(schema)

      @doc """
      Get your data from DB by passing ID as integer or list of keys
      """
      @spec read(integer | Keyword.t()) :: Ecto.Schema.t() | nil
      def read(id) when is_integer(id), do: Repo.get(unquote(schema), id)

      def read(opt) when is_list(opt), do: Repo.get_by(unquote(schema), opt)

      @doc """
      Inserts a struct defined via Ecto.Schema or a changeset.
      It returns {:ok, struct} if the struct has been successfully inserted or {:error, changeset} if there was a validation or a known constraint error.
      """
      @spec create(map | Keyword.t()) :: {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
      def create(attrs \\ %{}) when is_map(attrs) do
        %unquote(schema){}
        |> unquote(schema).changeset(attrs)
        |> Repo.insert()
      end

      @doc """
      Update a struct defined via Ecto.Schema or a changeset.
      Give ID as integer or Schema, and attributes for update.
      It returns {:ok, struct} if the struct has been successfully update or {:error, changeset} if there was a validation or a known constraint error.
      """
      @spec update(integer | Ecto.Schema.t() | Ecto.Changeset.t(), map | Keyword.t()) ::
              {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
      def update(id, attrs) when is_integer(id) do
        with %unquote(schema){} = struct <- read(id) do
          struct
          |> unquote(schema).changeset(attrs)
          |> Repo.update()
        end
      end

      def update(struct, attrs) when is_map(attrs) and is_map(struct) do
        struct
        |> unquote(schema).changeset(attrs)
        |> Repo.update()
      end

      @doc """
      Delete data by passing ID or Schema
      """
      @spec delete(integer | Ecto.Schema.t() | Ecto.Changeset.t()) ::
              {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
      def delete(id) when is_integer(id) do
        with %unquote(schema){} = struct <- read(id) do
          Repo.delete(struct)
        end
      end

      def delete(struct) when is_map(struct), do: Repo.delete(struct)
    end
  end
end
