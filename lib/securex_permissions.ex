defmodule SecureX.Permissions do
  alias SecureXWeb.{PermissionController}

  @moduledoc """
  Contains CRUD For Permissions.
  """

  @doc """
  Get list of Permissions by User Roles.

  ## Examples

      iex> list(["owner", "super_admin"])
      [
      %{ permission: 4, resource_id: "users", role_id: "admin"},
      %{ permission: 4, resource_id: "person_form", role_id: "super_admin"}
     ]
  """
  @spec list(list()) :: nonempty_list()
  def list(params) do
    case PermissionController.list_permissions(params) do
      [] -> {:error, :no_permissions_found}
      per -> {:ok, per}
    end
  end

  @doc """
  Add a Permission. You can send either `Atom Map` or `String Map` to add a Permission.

  ## Examples

      iex> add(%{"permission" => -1, "resource_id" => "users", "role_id" => "super_admin"})
      %Permission{
        id: 1,
        permission: -1,
        resource_id: "users",
        role_id: "super_admin"
      }
  """
  @spec add(map()) :: struct()
  def add(params) do
    case PermissionController.create(params) do
      {:error, error} -> {:error, error}
      {:ok, role} -> {:ok, role}
    end
  end

  @doc """
  Update a Permission. You can send either `Atom Map` or `String Map` to update a Permission.

   ## Examples

      iex> update(%{"id" => "1", "resource_id" => "users", "permission" => 4, "role_id" => "admin"})
      %Permission{
        id: 1,
        permission: 4,
        resource_id: "users",
        role_id: "admin"
      }

  """
  @spec update(map()) :: struct()
  def update(params) do
    case PermissionController.update(params) do
      {:error, error} -> {:error, error}
      {:ok, role} -> {:ok, role}
    end
  end

  @doc """
  Delete a Permission.

  ## Examples

      iex> delete(%{"id" => 1)
      %Permission{
        id: 1,
        permission: 4,
        resource_id: "users",
        role_id: "admin"
      }
  """
  @spec delete(map()) :: struct()
  def delete(params) do
    case PermissionController.delete(params) do
      {:error, error} -> {:error, error}
      {:ok, role} -> {:ok, role}
    end
  end
end
