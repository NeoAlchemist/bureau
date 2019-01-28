defmodule BureauWeb.SignIn do
  use Ecto.Schema
  import Ecto.Changeset
  alias Bureau.{Account, User}

  schema "" do
    field(:email, :string, virtual: true)
    field(:password, :string, virtual: true)
  end

  @required ~w(email password)a

  def verify(attrs \\ %{}) do
    %__MODULE__{}
    |> cast(attrs, @required)
    |> validate_required(@required)
    |> validate_format(:email, ~r/([\w-\.]+)@((?:[\w]+\.)+)([a-zA-Z]{2,4})/)
    |> validate_length(:email, min: 4)
    |> validate_length(:password, min: 8, max: 250)
    |> validate_format(:password, ~r/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$/)
    |> validate_user()
  end

  defp validate_user(
         changeset = %Ecto.Changeset{valid?: true, changes: %{email: email, password: pass}}
       ) do
    with user = %User{password_hash: hash, verified: true} <- Account.read(email: email),
         true <- Bureau.Account.Encryption.validate(pass, hash) do
      {:ok, user}
    else
      false ->
        add_error(changeset, :password, "password does not match")

      nil ->
        add_error(changeset, :email, "email cannot be found")

      _ ->
        add_error(changeset, :email, "please verify your email")
    end
  end

  defp validate_user(changeset), do: changeset
end
