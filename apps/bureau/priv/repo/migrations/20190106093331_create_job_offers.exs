defmodule Bureau.Repo.Migrations.CreateJobOffers do
  use Ecto.Migration

  def change do
    create table(:job_offers) do
      add :email, :string
      add :company_name, :string
      add :description, :text
      add :url, :string
      add :logo, :string
      add :position, :string
      add :close, :boolean, default: false, null: false
      add :country, :string
      add :location, :string
      add :remote, :boolean, default: false, null: false
      add :urgent, :boolean, default: false, null: false
      add :verified, :boolean, default: false, null: false

      timestamps()
    end

    execute(
      "CREATE INDEX index_job_offers_on_verified_idx ON job_offers(verified) WHERE verified = true"
    )

    execute(
      "CREATE INDEX index_job_offers_email_trgm_idx ON job_offers USING gin (email gin_trgm_ops);"
    )

    execute(
      "CREATE INDEX index_job_offers_company_name_trgm_idx ON job_offers USING gin (company_name gin_trgm_ops);"
    )

    execute(
      "CREATE INDEX index_job_offers_position_trgm_idx ON job_offers USING gin (position gin_trgm_ops);"
    )
  end
end
