defmodule Bureau.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string
      add :avatar, :string
      add :about, :text
      add :email, :string
      add :spell, :string
      add :password_hash, :text
      add :github_url, :string
      add :twitter_url, :string
      add :linkedIn_url, :string
      add :verified, :boolean, default: false, null: false
      add :open_hiring, :boolean, default: false, null: false
      add :oauth, :boolean, default: false, null: false

      timestamps()
    end

    execute("CREATE INDEX index_users_email_trgm_idx ON users USING gin (email gin_trgm_ops);")

    execute(
      "CREATE INDEX index_users_username_trgm_idx ON users USING gin (username gin_trgm_ops);"
    )

    execute("CREATE INDEX index_users_on_verified_idx ON users(verified) WHERE verified = true")
    execute("CREATE INDEX index_users_on_oauth_idx ON users(oauth) WHERE oauth = true")
    create unique_index(:users, [:email])
    create unique_index(:users, [:username])
  end
end
