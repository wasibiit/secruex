defmodule SecureX.Repo.Migrations.CreateTableResources do
  use Ecto.Migration

  def change do
    create table(:resources, primary_key: false) do
      add(:id, :string, primary_key: true)
      add(:name, :string)

      timestamps()
    end

    create(unique_index(:resources, [:id]))
  end
end