defmodule SecureXWeb.RoleController do
  @moduledoc false

  use SecureXWeb, :controller
  alias SecureX.SecureXContext, as: Context

  @doc """
  Create a Role,
  example: create(%{"id" => "super_admin", "name" => "Super Admin"})
  """
  @spec create(map()) :: struct()
  defp create(%{"id" => role} = params) do
    role = role
    |> String.trim
    |> String.downcase
    |> String.replace(" ", "_")
    Context.create_role(Map.merge(params, %{"id" => role}))
  end
  def create(_), do: {:error, :bad_input}

  @doc """
  Update Role,
  example: update(%Role{id: "super_admin", name: "Admin"}, %{"id" => "super_admin", "name" => "admin"})
  """
  @spec update(struct(), map()) :: struct()
  def update( %{__struct__: _} = role, %{"id" => _} = update_role)do
    Context.update_role(update_role, role)
  end
  def update(_, _), do: {:error, :bad_input}
end
