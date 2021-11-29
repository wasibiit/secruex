defmodule SecureXWeb.RoleController do
  @moduledoc false

  import Macro, only: [camelize: 1]
  use SecureXWeb, :controller
  alias SecureX.Common
  alias SecureX.Context

  @doc """
  Get list of roles with permissions,

  ## Examples

      iex> list_roles()
      [
      %Role{
        id: "super_admin",
        name: "Super Admin",
        permission: [
          ...
          %{resource_id: "users", permission: -1, role_id: "super_admin"},
          %{resource_id: "employees", permission: -1, role_id: "super_admin"},
          %{resource_id: "customer", permission: -1, role_id: "super_admin"}
          ...
        ]
      }
    ]
  """
  @spec list_roles() :: nonempty_list()
  def list_roles() do
    Context.list_roles_by()
  end

  @doc """
  Get a Role,

  ## Examples

      iex> get(%{"role" => "super_admin"})
      %Role{
        id: "super_admin",
        name: "Super Admin",
        permission: [
          ...
          %{resource_id: "users", permission: -1, role_id: "super_admin"},
          %{resource_id: "employees", permission: -1, role_id: "super_admin"},
          %{resource_id: "customer", permission: -1, role_id: "super_admin"}
          ...
        ]
      }
  """
  @spec get(map()) :: struct()
  def get(params) when params !== %{} do
    case params do
      %{role: role} -> get_role_sage(role)
      %{"role" => role} -> get_role_sage(role)
      _-> {:error, :bad_input}
    end
  end
  def get(_), do: {:error, :bad_input}

  defp get_role_sage(params) do
    case Context.get_role(params) do
      nil -> {:error, :no_role_found}
      role -> {:ok, role}
    end
  end

  @doc """
  Create a Role,

  ## Examples

      iex> create(%{"role" => "Super Admin"})
      %Role{
        id: "super_admin",
        name: "Super Admin",
        permission: [] || :no_resources_found || :permissions_already_set
      }
  """
  @spec create(map()) :: struct()
  def create(params) when params !== %{} do
    case params do
      %{role: role} -> create_role_sage(role)
      %{"role" => role} -> create_role_sage(role)
      _-> {:error, :bad_input}
    end
  end
  def create(_), do: {:error, :bad_input}

  defp create_role_sage(role) do
    with nil <- Context.get_role_by(role),
         {:ok, new_role} <- create_role(role),
         {:ok, permissions} <- create_permissions(role) do
      {:ok, Map.merge(new_role, %{permissions: permissions})}
    else
      %{__struct__: _} -> {:error, :alrady_exist}
      {:error, error} -> {:error, error}
    end
  end

  defp create_role(role) do
    name = role |> String.trim
    role = name
           |> String.downcase
           |> String.replace(" ", "_")
    Context.create_role(%{id: role, name: camelize(name)})
  end

  defp create_permissions(role_id) do
    case Context.get_permission_by([role_id]) do
      [] ->
        case Context.list_resources() do
          [] -> {:ok, :no_resources_found}
          resources ->
            {:ok,
              Enum.flat_map(resources, fn %{id: res_id} ->
                case Context.create_permission(%{resource_id: res_id, role_id: role_id, permission: -1}) do
                  {:ok, permission} -> [permission]
                  {:error, _} -> []
                end
              end)
            }
        end
      _-> {:ok, :permissions_already_set}
    end
  end

  @doc """
  Update Role,

  ## Examples

      iex> update(%{"id" => "super_admin", "role" => "Admin", "permissions" => [%{"resource_id" => "users", "permission" => 4}]})
      %Role{
        id: admin,
        name: "Admin",
        permissions: [] || :updated
      }
  """
  @spec update(map()) :: struct()
  def update(params) when params !== %{} do
    case params do
      %{id: role_id, role: _} -> update_role_sage(role_id, params)
      %{"id" => role_id, "role" => _} ->
        params = Common.keys_to_atoms(params)
        update_role_sage(role_id, params)
      _-> {:error, :bad_input}
    end
  end
  def update(_), do: {:error, :bad_input}

  defp update_role_sage(role_id, params) do
    with %{__struct__: _} = prev_role <- Context.get_role_by(role_id),
         {:ok, new_role} <- update_role(prev_role, params),
         {:ok, new_role} <- update_permissions(new_role, params) do
      {:ok, new_role}
    else
      nil -> {:error, :alrady_exist}
      {:error, error} -> {:error, error}
    end
  end

  defp update_role(prev_role, %{role: new_role}) do
    name = new_role |> String.trim
    updated_role = name
                   |> String.downcase
                   |> String.replace(" ", "_")
    if(prev_role.id !== updated_role) do
      new_role = Context.create_role(%{id: updated_role, name: camelize(name)})
      case Context.get_permissions(prev_role.id) do
        [] -> :nothing
        permissions -> Enum.map(permissions, fn per -> Context.update_permission(per, %{role_id: updated_role}) end)
      end
      case Context.get_user_roles_by(%{role_id: prev_role.id}) do
        [] -> :nothing
        user_roles -> Enum.map(user_roles, fn user_role -> Context.update_user_role(user_role, %{role_id: updated_role}) end)
      end
      Context.delete_role(prev_role)
      new_role
    else
      {:ok, prev_role}
    end
  end

  defp update_permissions(role, %{permissions: permissions}) when permissions !== [] do
    permissions = Enum.map(
      permissions,
      fn per ->
        case per do
          %{"resource_id" => resource_id, "permission" => permission} ->
            update_permission(resource_id, permission, role.id)
          %{resource_id: resource_id, permission: permission} ->
            update_permission(resource_id, permission, role.id)
          _-> :bad_input
        end
      end)
    {:ok, Map.merge(role, %{permissions: permissions})}
  end
  defp update_permissions(role, _), do: {:ok, role}

  defp update_permission(resource_id, updated_permission, role_id) do
    case Context.get_permission(resource_id, role_id) do
      nil -> :nothing
      permission -> Context.update_permission(permission, %{permission: updated_permission, role_id: role_id})
    end
  end

  @doc """
  Delete Role,

  ## Examples

      iex> delete(%{"id" => "admin")
      %Role{
        id: "admin",
        name: "Admin",
        permissions: :successfully_removed_permissions,
        user_roles: :successfully_removed_user_roles
      }
  """
  @spec delete(map()) :: struct()
  def delete(params) when params !== %{} do
    case params do
      %{id: role_id} -> delete_role_sage(role_id)
      %{"id" => role_id} -> delete_role_sage(role_id)
      _-> {:error, :bad_input}
    end
  end
  def delete(_), do: {:error, :bad_input}

  defp delete_role_sage(role_id) do
    with %{__struct__: _} = role <- Context.get_role_by(role_id),
         {:ok, permission} <- remove_permissions(role),
         {:ok, user_role} <- remove_user_roles(role),
         {:ok, role} <- delete_role(role) do
      {:ok, Map.merge(role, %{permissions: permission, user_roles: user_role})}
    else
      nil -> {:error, :doesnt_exist}
      {:error, error} -> {:error, error}
    end
  end

  defp remove_permissions(%{id: role_id}) do
    case Context.get_permissions(role_id) do
      [] -> {:ok, :already_removed}
      permissions ->
        {:ok, Enum.flat_map(permissions, fn per ->
          case Context.delete_permission(per) do
            {:ok, permissions} -> [permissions]
            {:error, _} -> []
          end
        end)}
    end
  end
  defp remove_permissions(_), do: {:ok, :invalid_role_id}

  defp remove_user_roles(%{id: role_id}) do
    case Context.get_user_roles_by(%{role_id: role_id}) do
      [] -> {:ok, :already_removed}
      user_roles ->
        Enum.map(user_roles, fn user_role -> Context.delete_user_role(user_role) end)
        {:ok, :successfully_removed_user_roles}
    end
  end
  defp remove_user_roles(_), do: {:ok, :invalid_role_id}

  defp delete_role(role) do
    case Context.delete_role(role) do
      {:error, error} -> {:error, error}
      {:ok, role} -> {:ok, role}
    end
  end
end
