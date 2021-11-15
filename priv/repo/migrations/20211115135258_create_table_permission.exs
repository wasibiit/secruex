defmodule SecureX.Repo.Migrations.CreateTablePermission do
  use Ecto.Migration

  def change do
    create table(:permissions) do
      add(:permission, :integer)
      add(:role_id, references(:roles, on_delete: :nothing, type: :string))
      add(:resource_id, references(:resources, on_delete: :nothing, type: :string))

      timestamps()
    end

    create(unique_index(:permissions, [:role_id, :resource_id]))
  end
end