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
  @spec list_roles(number(), number()) :: tuple()
  def list_roles(page \\ nil, page_size \\ 10),
    do: Context.list_roles_by(page, page_size)

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
  def get(%{role: role}), do: Context.get_role(role) |> default_resp

  def get(%{"role" => role}), do: Context.get_role(role) |> default_resp

  def get(_), do: error(:bad_input)

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
  def create(%{role: _} = input) do
    create_role_sage(input)
    |> default_resp(in: :create, key: :permissions, against: :permission)
  end

  def create(%{"role" => _} = input) do
    input
    |> keys_to_atoms
    |> create_role_sage()
    |> default_resp(in: :create, key: :permissions, against: :permission)
  end

  def create(_), do: error(:bad_input)

  defp create_role_sage(input) do
    new()
    |> run(:role, &get_role/2, &abort/3)
    |> run(:res, &get_resources/2, &abort/3)
    |> run(:create, &create_role/2, &abort/3)
    |> run(:permissions, &create_permissions/2, &abort/3)
    |> transaction(SecureX.Repo.repo(), input)
  end

  defp get_role(_, %{id: role}),
    do: role |> trimmed_downcase |> Context.get_role_by() |> default_resp()

  defp get_role(_, %{role: role}),
    do: role |> trimmed_downcase |> Context.get_role_by() |> default_resp(mode: :reverse)

  defp create_role(_, %{role: role}), do: role |> create_role() |> default_resp()

  defp create_role(role) do
    name = role |> String.trim()
    role = role |> trimmed_downcase()

    Context.create(Role, %{id: role, name: camelize(name)})
  rescue
    _ -> error(:role_already_exist)
  end

  defp get_resources(_, _), do: Context.list_resources() |> default_resp()

  defp create_permissions(%{create: %{id: role_id}}, %{permissions: permissions}) do
    Context.get_permission_by([role_id])
    |> then(fn
      [] ->
        permissions =
          permissions
          |> Enum.map(fn map ->
            Map.put(map, :role_id, role_id) |> insert_timestamp
          end)

        Permission
        |> Context.create_all(permissions)
        |> default_resp(mode: :reverse, msg: :permissions_added_successfully)

      _ ->
        ok(:permissions_already_set)
    end)
  end

  defp create_permissions(%{create: %{id: role_id}, res: resources}, _) do
    Context.get_permission_by([role_id])
    |> then(fn
      [] ->
        permissions =
          resources
          |> Enum.map(fn %{id: res_id} ->
            %{
              resource_id: res_id,
              role_id: role_id,
              permission: -1
            }
            |> insert_timestamp
          end)

        Permission
        |> Context.create_all(permissions)
        |> default_resp(mode: :reverse, msg: :permissions_added_successfully)

      _ ->
        ok(:permissions_already_set)
    end)
  end

  defp insert_timestamp(map) do
    map
    |> Map.merge(%{
      updated_at: DateTime.truncate(DateTime.utc_now(), :second),
      inserted_at: DateTime.truncate(DateTime.utc_now(), :second)
    })
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
  @spec update(map()) :: tuple()
  def update(%{id: _, role: _} = input),
    do:
      update_role_sage(input)
      |> default_resp(in: :update, key: :permissions, against: :permission)

  def update(%{"id" => _, "role" => _} = input) do
    input
    |> keys_to_atoms
    |> update_role_sage()
    |> default_resp(in: :update, key: :permissions, against: :permission)
  end

  def update(_), do: error(:bad_input)

  defp update_role_sage(input) do
    new()
    |> run(:role, &get_role/2, &abort/3)
    |> run(:check, &check_role/2, &abort/3)
    |> run(:update, &update_role/2, &abort/3)
    |> run(:permissions, &update_permissions/2, &abort/3)
    |> transaction(SecureX.Repo.repo(), input)
  end

  defp check_role(%{role: %{id: role_id}}, %{role: role}),
    do: if(role_id !== downcase(role), do: default_resp(true), else: default_resp(false))

  defp check_role(%{role: nil}, _), do: error()

  defp update_role(%{role: %{id: role_id} = prev_role, check: true}, %{role: role}) do
    {:ok, %{id: new_role_id}} = new_role = role |> create_role()

    Context.update_permissions(role_id, new_role_id)

    Context.update_user_roles(role_id, new_role_id)

    Context.delete_role(prev_role)
    new_role
  end

  defp update_role(%{role: role}, _), do: role |> ok()

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

  defp update_permissions(%{update: role}, _), do: role |> ok()

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

      iex> delete(%{"id" => "admin"})
      {:ok, %Role{
        id: "admin",
        name: "Admin",
        permissions: :successfully_removed_permissions,
        user_roles: :successfully_removed_user_roles
      }}
  """
  @spec delete(map()) :: tuple()
  def delete(%{id: _} = input),
    do:
      delete_role_sage(input)
      |> default_resp(in: :delete, key: :permissions, against: :permission)

  def delete(%{"id" => _} = input) do
    input
    |> keys_to_atoms
    |> delete_role_sage()
    |> default_resp(in: :delete, key: :permissions, against: :permission)
  end

  def delete(_), do: error(:bad_input)

  defp delete_role_sage(input) do
    new()
    |> run(:role, &get_role/2, &abort/3)
    |> run(:permissions, &delete_permissions/2, &abort/3)
    |> run(:user_roles, &delete_user_roles/2, &abort/3)
    |> run(:delete, &delete_role/2, &abort/3)
    |> transaction(SecureX.Repo.repo(), input)
  end

  defp delete_permissions(%{role: %{id: role_id}}, _),
    do:
      Context.delete_permissions(role_id)
      |> default_resp(mode: :reverse, msg: :permissions_removed_successfully)

  defp delete_user_roles(%{role: %{id: role_id}}, _),
    do:
      Context.delete_user_roles(role_id)
      |> default_resp(mode: :reverse, msg: :user_roles_removed_successfully)

  defp delete_role(%{role: role}, _), do: Context.delete_role(role) |> default_resp
end
