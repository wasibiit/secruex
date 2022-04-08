defmodule SecureX.Permission do
  @moduledoc false
  use SecureX.Schema

  schema "permissions" do
    field :permission, :integer

    belongs_to :resource, SecureX.Resource, type: :string
    belongs_to :role, SecureX.Role, type: :string

    timestamp()
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
