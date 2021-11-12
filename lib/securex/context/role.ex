defmodule SecureX.Role do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "roles" do
    field :id, :string, primary_key: true
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(roles, attrs) do
    roles
    |> cast(attrs, [:id, :name])
    |> validate_required([:id])
  end
end
