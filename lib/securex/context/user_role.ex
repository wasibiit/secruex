defmodule SecureX.UserRole do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  schema "user_roles" do
    belongs_to :role, SecureX.Role, type: :string
    belongs_to :user, Application.get_env(:securex, :schema)

    timestamps()
  end

  @doc false
  def changeset(user_role, attrs) do
    user_role
    |> cast(attrs, [:user_id, :role_id])
    |> validate_required([:user_id])
  end
end
