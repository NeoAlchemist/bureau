defmodule Bureau.JobOffer do
  use Ecto.Schema
  import Ecto.Changeset

  schema "job_offers" do
    field :company_name, :string
    field :description, :string
    field :email, :string
    field :url, :string
    field :logo, :string
    field :position, :string
    field :country, :string
    field :location, :string
    field :remote, :boolean, default: false
    field :close, :boolean, default: false
    field :urgent, :boolean, default: false
    field(:verified, :boolean, default: false)

    timestamps()
  end

  @required_fields ~w(email company_name description url remote country location)a
  @optional_fields ~w(logo position urgent verified close)a

  @doc false
  def changeset(job_offer, attrs \\ %{}) do
    job_offer
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_format(:email, ~r/([\w-\.]+)@((?:[\w]+\.)+)([a-zA-Z]{2,4})/)
    |> validate_length(:email, min: 4)
    |> validate_length(:company_name, min: 3)
    |> validate_length(:url, min: 8)
    |> validate_length(:url, min: 8)
    |> validate_length(:description, min: 50)
    |> validate_format(:url, ~r/^(http[s]?:\/\/)?[^\s(["<,>]*\.[^\s[",><]*/)
    |> validate_format(
      :logo,
      ~r/^(http[s]?:\/\/)?[^\s(["<,>]*\.[^\s[",><]+\.(?:jpg|gif|png|jpeg)$/
    )
  end
end
