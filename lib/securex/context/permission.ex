defmodule SecureX.Permission do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  schema "permissions" do
    field :permission, :integer

    belongs_to :resource, SecureX.Resource, type: :string
    belongs_to :role, SecureX.Role, type: :string

    timestamps()
  end

  @doc false
  def changeset(permission, attrs) do
    permission
    |> cast(attrs, [:permission, :resource_id, :role_id])
    |> validate_required([:permission])
  end
end
