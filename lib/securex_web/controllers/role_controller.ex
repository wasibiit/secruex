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
  def get(params) when params !== %{} do
    case params do
      %{role: role} -> get_role(role)
      %{"role" => role} -> get_role(role)
      _ -> {:error, :bad_input}
    end
  end

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

  defp get_role(_, %{role: role}),
  do: role |> trimmed_downcase |> Context.get_role_by() |> default_resp(mode: :reverse, msg: :alrady_exist)

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
          resources |> Enum.map(fn %{id: res_id} -> %{resource_id: res_id, role_id: role_id, permission: -1} end)
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
  def update(params) when params !== %{} do
    case params do
      %{id: role_id, role: _} ->
        update_role_checks(role_id, params)

      %{"id" => role_id, "role" => _} ->
        params = keys_to_atoms(params)
        update_role_checks(role_id, params)

      _ ->
        {:error, :bad_input}
    end
  end

  def update(_), do: {:error, :bad_input}

  defp update_role_checks(role_id, params) do
    role_id = role_id |> trimmed_downcase
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
    name = new_role |> String.trim()

    updated_role =
      name
      |> String.downcase()
      |> String.replace(" ", "_")

    if prev_role.id !== updated_role do
      new_role = Context.create_role(%{id: updated_role, name: camelize(name)})

      case Context.get_permissions(prev_role.id) do
        [] ->
          :nothing

        permissions ->
          Enum.each(permissions, fn per ->
            Context.update_permission(per, %{role_id: updated_role})
          end)
      end

      case Context.get_user_roles_by(%{role_id: prev_role.id}) do
        [] ->
          :nothing

        user_roles ->
          Enum.each(user_roles, fn user_role ->
            Context.update_user_role(user_role, %{role_id: updated_role})
          end)
      end

      Context.delete_role(prev_role)
      new_role
    else
      {:ok, prev_role}
    end
  end

  defp update_permissions(role, %{permissions: permissions}) when permissions !== [] do
    permissions =
      Enum.map(
        permissions,
        fn per ->
          case per do
            %{"resource_id" => resource_id, "permission" => permission} ->
              update_permission(resource_id, permission, role.id)

            %{resource_id: resource_id, permission: permission} ->
              update_permission(resource_id, permission, role.id)

            _ ->
              :bad_input
          end
        end
      )

    {:ok, Map.merge(role, %{permissions: permissions})}
  end

  defp update_permissions(role, _), do: {:ok, role}

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
  def delete(params) when params !== %{} do
    case params do
      %{id: role_id} -> delete_role_checks(role_id)
      %{"id" => role_id} -> delete_role_checks(role_id)
      _ -> {:error, :bad_input}
    end
  end

  def delete(_), do: {:error, :bad_input}

  defp delete_role_checks(role_id) do
    role_id = role_id |> trimmed_downcase
    with %{__struct__: _} = role <- Context.get_role_by(role_id),
         {:ok, permission} <- delete_permissions(role),
         {:ok, user_role} <- delete_user_roles(role),
         {:ok, role} <- delete_role(role) do
      {:ok, Map.merge(role, %{permissions: permission, user_roles: user_role})}
    else
      nil -> {:error, :doesnt_exist}
      {:error, error} -> {:error, error}
    end
  end

  defp delete_permissions(%{id: role_id}) do
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

  defp delete_permissions(_), do: {:ok, :invalid_role_id}

  defp delete_user_roles(%{id: role_id}) do
    case Context.get_user_roles_by(%{role_id: role_id}) do
      [] ->
        {:ok, :already_removed}

      user_roles ->
        Enum.each(user_roles, fn user_role -> Context.delete_user_role(user_role) end)
        {:ok, :successfully_removed_user_roles}
    end
  end

  defp delete_user_roles(_), do: {:ok, :invalid_role_id}

  defp delete_role(role) do
    case Context.delete_role(role) do
      {:error, error} -> {:error, error}
      {:ok, role} -> {:ok, role}
    end
  end
end
