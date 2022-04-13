defmodule SecureX.UserRole do
  @moduledoc false
  use SecureX.Schema

  schema "user_roles" do
    belongs_to(:role, SecureX.Role, type: :string)

    belongs_to(
      :user,
        Application.get_env(:securex, :schema) || raise("Set SecureX Configuration")
    )

    timestamp()
  end

  @doc false
  def changeset(user_role, attrs) do
    user_role
    |> cast(attrs, [:user_id, :role_id])
    |> validate_required([:user_id])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:role_id)
  end
end
