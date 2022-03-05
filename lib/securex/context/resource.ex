defmodule SecureX.Resource do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "resources" do
    field(:id, :string, primary_key: true)
    field(:name, :string)

    timestamps()
  end

  @doc false
  def changeset(resource, attrs) do
    resource
    |> cast(attrs, [:id, :name])
    |> validate_required([:id])
  end
end
