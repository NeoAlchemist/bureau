defmodule CRUD do
  @spec __using__(list({atom, Ecto.Schema.t()})) :: any
  defmacro __using__(schema: schema) do
    quote do
      @doc """
      Check if schema is a valide module and then inject expression, or raise un error
      """
      alias Bureau.Repo
      alias unquote(schema)

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
