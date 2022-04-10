defmodule SecureXWeb.RoleController do
  @moduledoc false

  use SecureXWeb, :controller
  alias SecureX.{Context, Role, Permission}

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

  @spec get(map()) :: tuple()
  def get(%{role: role}), do: get_role(role)

  def get(%{"role" => role}), do: get_role(role)

  def get(_), do: {:error, :bad_input}

  @doc """
  Create a Role,

  ## Examples

      iex> create(%{"role" => "Super Admin", "permissions" => [%{}]})
      %Role{
        id: "super_admin",
        name: "Super Admin",
        permission: [] || :no_resources_found || :permissions_already_set
      }
  """
  @spec create(map()) :: tuple()
  def create(%{role: _} = input), do: create_role_sage(input)

  def create(%{"role" => _} = input), do: input |> keys_to_atoms |> create_role_sage()

  def create(_), do: {:error, :bad_input}

  defp create_role_sage(input) do
    new()
    |> run(:role, &get_role/2, &abort/3)
    |> run(:res, &get_resources/2, &abort/3)
    |> run(:create, &create_role/2, &abort/3)
    |> run(:create_permissions, &create_permissions/2, &abort/3)
    |> transaction(SecureX.Repo, input)
  end

  defp get_role(_, %{role: role} = params),
    do:
      params["id"] ||
        role
        |> trimmed_downcase
        |> Context.get_role_by()
        |> default_resp(mode: :reverse, msg: :alrady_exist)

  defp get_role(params) do
    case Context.get_role(params) do
      nil -> {:error, :no_role_found}
      role -> {:ok, role}
    end
  end

  defp create_role(_, %{role: role}) do
    name = role |> String.trim()
    role = role |> downcase()

    Context.create(Role, %{id: role, name: camelize(name)}) |> default_resp()
  end

  defp get_resources(_, _), do: Context.list_resources() |> default_resp()

  defp create_permissions(%{create: %{id: role_id}}, %{permissions: permissions}) do
    Context.get_permission_by([role_id])
    |> then(fn
      [] ->
        permissions = permissions |> Enum.map(fn map -> Map.put(map, :role_id, role_id) end)
        Permission |> Context.create_all(permissions) |> default_resp()

      _ ->
        {:ok, :permissions_already_set}
    end)
  end

  defp create_permissions(%{create: %{id: role_id}, res: resources}, _) do
    Context.get_permission_by([role_id])
    |> then(fn
      [] ->
        permissions =
          resources
          |> Enum.map(fn %{id: res_id} ->
            %{resource_id: res_id, role_id: role_id, permission: -1}
          end)

        Permission |> Context.create_all(permissions) |> default_resp()

      _ ->
        {:ok, :permissions_already_set}
    end)
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
  def update(%{id: _, role: _} = input), do: update_role_sage(input)

  def update(%{"id" => _, "role" => _} = input),
    do: input |> keys_to_atoms |> update_role_sage()

  def update(_), do: {:error, :bad_input}

  defp update_role_sage(input) do
    new()
    |> run(:role, &get_role/2, &abort/3)
    |> run(:update, &update_role/2, &abort/3)
    |> run(:permission, &update_permissions/2, &abort/3)
    |> transaction(SecureX.Repo, input)
  end

  defp update_role(%{role: %{id: role_id} = prev_role}, %{role: new_role}) do
    name = new_role |> String.trim()
    updated_role = new_role |> downcase()

    if role_id !== updated_role do
      new_role = Context.create_role(%{id: updated_role, name: camelize(name)}) |> default_resp()

      case Context.get_permissions(role_id) do
        [] ->
          :nothing

        permissions ->
          Enum.each(permissions, fn per ->
            Context.update_permission(per, %{role_id: updated_role}) |> default_resp()
          end)
      end

      case Context.get_user_roles_by(%{role_id: role_id}) do
        [] ->
          :nothing

        user_roles ->
          Enum.each(user_roles, fn user_role ->
            Context.update_user_role(user_role, %{role_id: updated_role}) |> default_resp()
          end)
      end

      Context.delete_role(prev_role) |> default_resp()
      new_role
    else
      {:ok, prev_role}
    end
  end

  defp update_permissions(%{update: %{id: role_id} = role}, %{permissions: permissions})
       when permissions !== [] do
    permissions =
      Enum.map(
        permissions,
        fn per ->
          case per do
            %{"resource_id" => resource_id, "permission" => permission} ->
              update_permission(resource_id, permission, role_id) |> default_resp

            %{resource_id: resource_id, permission: permission} ->
              update_permission(resource_id, permission, role_id) |> default_resp

            _ ->
              :bad_input
          end
        end
      )

    {:ok, Map.merge(role, %{permissions: permissions})}
  end

  defp update_permissions(%{update: role}, _), do: {:ok, role}

  defp update_permission(resource_id, updated_permission, role_id) do
    case Context.get_permission(resource_id, role_id) do
      nil ->
        :nothing

      permission ->
        Context.update_permission(permission, %{permission: updated_permission, role_id: role_id})
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
  def delete(%{id: _} = input), do: delete_role_sage(input)

  def delete(%{"id" => _} = input),
    do: input |> keys_to_atoms |> delete_role_sage()

  def delete(_), do: {:error, :bad_input}

  defp delete_role_sage(input) do
    new()
    |> run(:role, &get_role/2, &abort/3)
    |> run(:permission, &delete_permissions/2, &abort/3)
    |> run(:user_role, &delete_user_roles/2, &abort/3)
    |> run(:delete, &delete_role/2, &abort/3)
    |> transaction(SecureX.Repo, input)
  end

  defp delete_permissions(%{role: %{id: role_id}}, _) do
    case Context.get_permissions(role_id) do
      [] ->
        {:ok, :already_removed}

      permissions ->
        {:ok,
         Enum.flat_map(permissions, fn per ->
           case Context.delete_permission(per) do
             {:ok, permissions} -> [permissions]
             {:error, _} -> []
           end
         end)}
    end
  end

  defp delete_user_roles(%{role: %{id: role_id}}, _) do
    case Context.get_user_roles_by(%{role_id: role_id}) do
      [] ->
        {:ok, :already_removed}

      user_roles ->
        Enum.each(user_roles, fn user_role ->
          Context.delete_user_role(user_role) |> default_resp
        end)

        {:ok, :successfully_removed_user_roles}
    end
  end

  defp delete_role(%{role: role, permission: permission, user_role: user_role}, _) do
    case Context.delete_role(role) do
      {:error, error} -> {:error, error}
      {:ok, role} -> {:ok, Map.merge(role, %{permissions: permission, user_roles: user_role})}
    end
  end
end
