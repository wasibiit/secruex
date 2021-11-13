defmodule SecureX.Roles do
  alias SecureXWeb.{ RoleController }

  @moduledoc """

  """

  @doc """
  Create a Role. You can send either `Atom Map` or `String Map` to add Role. If you have existing resources,
  it will create default permissions against this role

  ## Examples

      iex> add_role(%{"role" => "Super Admin"})
      %Role{
        id: "super_admin",
        name: "Super Admin",
        permission: [
          %{resource_id: "users", permission: -1, role_id: "super_admin"},
          %{resource_id: "employees", permission: -1, role_id: "super_admin"},
          %{resource_id: "customer", permission: -1, role_id: "super_admin"}
        ]
      }

  Your will get Role `struct()` with all permissions created for the resources if they exist.
  `list()`of permissions you will get in simple `map()`.
  """
  @spec add_role(map()) :: struct()
  def add_role(params) do
    case RoleController.create(params) do
      {:error, error} -> {:error, error}
      {:ok, role} -> {:ok, role}
    end
  end

  @doc """
  Update a Role. You can update any role along with its permissions if you want, if you pass `:permissions`
  in your params. You can send either `Atom Map` or `String Map` to update Role. It will automatically
  update that `role_id` in `UserRoles` and `Permissions` table, if you intend to update any role.

  ## Examples

      iex> update(%{"id" => "super_admin", "role" => "Admin", "permissions" => [%{"resource_id" => "users", "permission" => 4}]})
      %Role{
        id: admin,
        name: "Admin",
        permission: [
          %{resource_id: "users", permission: 4, role_id: "admin"}
        ]
      }

  It will return with permissions that you sent in params to change.
  """
  @spec update_role(map()) :: struct()
  def update_role(params) do
    case RoleController.update(params) do
      {:error, error} -> {:error, error}
      {:ok, role} -> {:ok, role}
    end
  end
end