defmodule Bureau.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Bureau.Account.Encryption, as: Encrypt

  schema "users" do
    field(:username, :string)
    field(:avatar, :string)
    field(:about, :string)
    field(:spell, :string)
    field(:email, :string)
    field(:password, :string, virtual: true)
    field(:password_confirmation, :string, virtual: true)
    field(:new_password, :string, virtual: true)
    field(:password_hash, :string)
    field(:open_hiring, :boolean, default: false)
    field(:verified, :boolean, default: false)

    # social
    field(:github_url, :string)
    field(:twitter_url, :string)
    field(:linkedIn_url, :string)

    # login with oauth
    field(:oauth, :boolean, default: false)

    timestamps()
  end

  @required_fields ~w(email username)a
  @optional_fields ~w(oauth open_hiring github_url twitter_url linkedIn_url password_confirmation verified spell avatar about password password_hash new_password)a
  @link_regex ~r/^(http[s]?:\/\/)?[^\s(["<,>]*\.[^\s[",><]*/

  @doc false
  def changeset(%__MODULE__{} = user, attrs \\ %{}) do
    user
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_length(:username, min: 3)
    |> validate_format(:username, ~r/^[a-zA-Z ]+$/)
    |> validate_format(:email, ~r/([\w-\.]+)@((?:[\w]+\.)+)([a-zA-Z]{2,4})/)
    |> validate_length(:email, min: 4)
    |> validate_length(:spell, max: 255)
    |> unique_constraint(:email)
    |> unique_constraint(:username)
    |> validate_length(:password, min: 8, max: 250)
    |> validate_format(:password, ~r/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$/,
      message: "Should include both lower and upper case characters"
    )
    |> validate_confirmation(:password, message: "does not match password")
    |> validate_length(:new_password, min: 8, max: 250)
    |> validate_format(:new_password, ~r/(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$/,
      message: "Should include both lower and upper case characters"
    )
    |> validate_format(:github_url, @link_regex)
    |> validate_format(:twitter_url, @link_regex)
    |> validate_format(:linkedIn_url, @link_regex)
    |> put_password_hash()
  end

  defp put_password_hash(
         changeset = %Ecto.Changeset{
           valid?: true,
           data: %{password_hash: hash},
           changes: %{password: pass, new_password: new}
         }
       )
       when not is_nil(pass) and not is_nil(new) and not is_nil(hash) do
    with true <- Encrypt.validate(pass, hash) do
      changeset
      |> put_change(:password_hash, Encrypt.hash(new))
    else
      _ -> add_error(changeset, :password, "does not match old password")
    end
  end

  defp put_password_hash(changeset = %Ecto.Changeset{valid?: true, changes: %{password: pass}})
       when not is_nil(pass) do
    changeset
    |> put_change(:password_hash, Encrypt.hash(pass))
  end

  defp put_password_hash(changeset = %Ecto.Changeset{valid?: true, data: %{password_hash: hash}})
       when is_nil(hash) do
    changeset
    |> validate_required([:password, :password_confirmation])
  end

  defp put_password_hash(changeset), do: changeset
end
