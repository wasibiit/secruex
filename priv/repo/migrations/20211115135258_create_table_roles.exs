defmodule SecureX.Repo.Migrations.CreateTableRoles do
  use Ecto.Migration

  def change do
    create table(:roles, primary_key: false) do
      add(:role, :string, null: false, primary_key: true, unique: true)
      add(:name, :string)

      timestamps()
    end

    create(unique_index(:roles, [:id]))
  end
end