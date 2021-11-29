defmodule SecureX.UserRole do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key if (Application.get_env(:securex, :type) === :binary_id),
               do: {:id, :binary_id, autogenerate: true}, else: {:id, :id, autogenerate: true}
  @foreign_key_type if (Application.get_env(:securex, :type) === :binary_id),
                    do: Ecto.UUID, else: :id

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
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:role_id)
  end
end
