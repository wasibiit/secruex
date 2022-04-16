defmodule SecureX.Roles do
  alias SecureXWeb.{RoleController}

  @moduledoc """
  Contains CRUD For Roles.
  """

  @doc """
  Get list of Roles with Permissions.

  ## Examples

      iex> list()
      [
      %Role{
        id: "super_admin",
        name: "Super Admin",
        permission: [
          %{resource_id: "users", permission: -1, role_id: "super_admin"},
          %{resource_id: "employees", permission: -1, role_id: "super_admin"},
          %{resource_id: "customer", permission: -1, role_id: "super_admin"}
        ]
      }
     ]
  """
  @spec list(number(), number()) :: tuple()
  def list(page \\ nil, page_size \\ 10),
    do: RoleController.list_roles(page, page_size)

  @doc """
  Get a Role.

  ## Examples

      iex> get(%{"role" => "super_admin"})
      %Role{
        id: "super_admin",
        name: "Super Admin",
        permission: [
          %{resource_id: "users", permission: -1, role_id: "super_admin"},
          %{resource_id: "employees", permission: -1, role_id: "super_admin"},
          %{resource_id: "customer", permission: -1, role_id: "super_admin"}
        ]
      }
  """
  @spec get(map()) :: tuple()
  def get(params), do: RoleController.get(params)

  @doc """
  Add a Role. You can send either `Atom Map` or `String Map` to add a Role. If you have existing resources,
  it will create default permissions against this role.

  ## Examples

      iex> add(%{"role" => "Super Admin"})
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
  @spec add(map()) :: tuple()
  def add(params), do: RoleController.create(params)

  @doc """
  Update a Role. You can update any role along with its permissions if you want, if you pass `:permissions`
  in your params. You can send either `Atom Map` or `String Map` to update  sRole. It will automatically
  update that `role_id` in `UserRoles` and `Permissions` table, if you intend to update any role.

  ## Examples

      iex> update(%{"id" => "super_admin", "role" => "Admin", "permissions" => [%{"resource_id" => "users", "permission" => 4}]})
      {:ok, %Role{
              id: admin,
              name: "Admin",
              permission: [%{resource_id: "users", permission: 4, role_id: "admin"}]
          }
      }

  It will return with permissions that you sent in params to change.
  """
  @spec update(map()) :: tuple()
  def update(params), do: RoleController.update(params)

  @doc """
  Delete a Role. All `Permissions` and `UserRoles` will be removed against this role.

  ## Examples

      iex> delete(%{"id" => "admin")
      %Role{
        id: admin,
        name: "Admin",
        permissions: :successfully_removed_permissions,
        user_roles: :successfully_removed_user_roles
      }
  """
  @spec delete(map()) :: tuple()
  def delete(params), do: RoleController.delete(params)
end
