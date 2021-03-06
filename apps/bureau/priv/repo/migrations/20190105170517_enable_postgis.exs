defmodule Bureau.Repo.Migrations.EnablePostgis do
  use Ecto.Migration

  def up do
    execute "CREATE EXTENSION IF NOT EXISTS postgis"
    execute "CREATE EXTENSION IF NOT EXISTS pg_trgm"
  end

  def down do
    execute "DROP EXTENSION IF EXISTS postgis"
    execute "DROP EXTENSION IF EXISTS pg_trgm"
  end
end
