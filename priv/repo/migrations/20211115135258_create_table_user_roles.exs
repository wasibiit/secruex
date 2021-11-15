defmodule SecureX.Repo.Migrations.CreateTableUserRoles do
  use Ecto.Migration

  def change do
    create table(:user_roles) do
      add(:role_id, references(:roles, on_delete: :nothing, type: :string))
      add(:user_id, references(:users, on_delete: :nothing))

      timestamps()
    end

    create(unique_index(:user_roles, [:user_id, :role_id]))
  end
end