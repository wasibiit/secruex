defmodule SecureX.Permission do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key if Application.get_env(:securex, :type) === :binary_id,
                 do: {:id, :binary_id, autogenerate: true},
                 else: {:id, :id, autogenerate: true}
  @foreign_key_type if Application.get_env(:securex, :type) === :binary_id,
                      do: Ecto.UUID,
                      else: :id

  schema "permissions" do
    field(:permission, :integer)

    belongs_to(:resource, SecureX.Resource, type: :string)
    belongs_to(:role, SecureX.Role, type: :string)

    timestamps()
  end

  @doc false
  def changeset(permission, attrs) do
    permission
    |> cast(attrs, [:permission, :resource_id, :role_id])
    |> validate_required([:permission, :role_id, :resource_id])
    |> unique_constraint([:role_id, :resource_id])
    |> foreign_key_constraint(:role_id)
    |> foreign_key_constraint(:resource_id)
  end
end
