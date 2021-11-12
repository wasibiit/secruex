defmodule SecureXWeb.RoleController do
  @moduledoc false

  import Macro, only: [camelize: 1]
  use SecureXWeb, :controller
  alias SecureX.SecureXContext, as: Context
  alias SecureX.Common

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
              Enum.each(resources, fn %{id: res_id} ->
                Context.create_permission(%{resource_id: res_id, role_id: role_id, permission: -1})
              end)
            }
        end
      permissions -> {:ok, :permissions_already_set}
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
      %{id: role_id} -> update_role_sage(role_id, params)
      %{"id" => role_id} ->
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

  defp update_role(prev_role, %{role: new_role} = params) do
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
        end
      end)
    {:ok, Map.merge(role, %{permissions: permissions})}
  end
  defp update_permissions(role, _), do: {:ok, role}

  defp update_permission(resource_id, permission, role_id) do
    case Context.get_permissions(resource_id, role_id) do
      nil -> :nothing
      permission -> Context.update_permission(permission, %{permission: permission, role_id: role_id})
    end
  end
end
