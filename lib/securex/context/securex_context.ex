defmodule SecureX.Context do
  @moduledoc false

  import Ecto.Query, warn: false
  import SecureX.Repo, only: [repo: 0]

  alias SecureX.{Role, Permission, Resource, UserRole}

  @spec preload_role(struct()) :: struct()
  def preload_role(data), do: repo().preload(data, [:permissions])

  def list_roles do
    from(r in Role,
      order_by: [asc: r.id]
    )
    |> repo().all
  end

  def list_roles(offset, limit \\ 10) do
    from(r in Role,
      offset: ^offset,
      limit: ^limit,
      order_by: [asc: r.id]
    )
    |> repo().all
  end

  def list_roles_by() do
    from(r in Role,
      left_join: p in Permission,
      on: p.role_id == r.id,
      order_by: [asc: r.id],
      preload: [{:permissions, p}]
    )
    |> repo().all
  end

  def get_role(role_id) do
    from(r in Role,
      left_join: p in Permission,
      on: p.role_id == r.id,
      where: r.id == ^role_id,
      preload: [{:permissions, p}]
    )
    |> repo().one
  end

  def get_role_by(id),
    do: from(r in Role, where: r.id == ^id) |> repo().one

  def create_role(attrs \\ %{}) do
    %Role{}
    |> Role.changeset(attrs)
    |> repo().insert()
  end

  def update_role(%Role{} = role, attrs) do
    role
    |> Role.changeset(attrs)
    |> repo().update()
  end

  def delete_role(%Role{} = role) do
    repo().delete(role)
  end

  def change_role(%Role{} = role, attrs \\ %{}) do
    Role.changeset(role, attrs)
  end

  @spec preload_resources(struct()) :: struct()
  def preload_resources(data), do: repo().preload(data, [])

  def list_resources do
    repo().all(from(r in Resource, order_by: [asc: r.name]))
  end

  def get_resource(res) do
    from(r in Resource, where: r.id == ^res)
    |> repo().one
  end

  def get_resource_by(res_id) do
    res_id =
      res_id
      |> String.trim()
      |> String.replace(" ", "_")
      |> String.downcase()

    from(r in Resource, where: r.id == ^res_id)
    |> repo().one
  end

  def create_resource(attrs \\ %{}) do
    %Resource{}
    |> Resource.changeset(attrs)
    |> repo().insert()
  end

  def update_resource(%Resource{} = resource, attrs) do
    resource
    |> Resource.changeset(attrs)
    |> repo().update()
  end

  def delete_resource(%Resource{} = resource) do
    repo().delete(resource)
  end

  @spec preload_permissions(struct()) :: struct()
  def preload_permissions(data), do: repo().preload(data, [:role, :resource])

  def list_permissions(roles) do
    from(p in Permission,
      where: p.role_id in ^roles,
      select: %{
        permission: p.permission,
        resource_id: p.resource_id,
        role_id: p.role_id
      }
    )
    |> repo().all
  end

  #  def list_permissions_by(role_ids) do
  #    from(p in Permission,
  #      join: r in Resource, on: p.resource_id == r.id,
  #      join: u in User, on: p.user_id == ^user_id,
  #      distinct: p.id,
  #      select: %{
  #        id: p.id,
  #        resource: r.res,
  #        permission: p.permission
  #      }
  #    )
  #    |> repo().all
  #  end

  def get_permission(res_id, role_id) do
    from(p in Permission, where: p.resource_id == ^res_id and p.role_id == ^role_id)
    |> preload_clause
    |> repo().one
  end

  def get_permission(per_id) do
    from(p in Permission, where: p.id == ^per_id)
    |> preload_clause
    |> repo().one
  end

  def update_permissions(role_id, role) do
    from(p in Permission, where: p.role_id == ^role_id)
    |> preload_clause
    |> repo().update_all(set: [role_id: role])
  end

  defp preload_clause(query), do: query |> preload([p], [:resource, :role])

  def get_permissions_by_res_id(res_id) do
    from(p in Permission,
      join: r in Resource,
      on: p.resource_id == r.id,
      where: p.resource_id == ^res_id,
      select: p
    )
    |> repo().all
  end

  def get_permission_by(roles) do
    from(p in Permission,
      join: r in Resource,
      on: p.resource_id == r.id,
      where: p.role_id in ^roles,
      select: %{
        permission: p.permission,
        resource_id: p.resource_id,
        role_id: p.role_id
      }
    )
    |> repo().all
  end

  def get_permission_by(res_id, roles) do
    from(p in Permission,
      where: p.resource_id == ^res_id,
      where: p.role_id in ^roles,
      order_by: [desc: p.permission],
      limit: 1,
      select: %{
        permission: p.permission,
        resource_id: p.resource_id,
        role_id: p.role_id
      }
    )
    |> repo().one
  end

  def create_permission(attrs \\ %{}) do
    %Permission{}
    |> Permission.changeset(attrs)
    |> repo().insert()
  end

  def update_permission(%Permission{} = permission, attrs) do
    permission
    |> Permission.changeset(attrs)
    |> repo().update()
  end

  def delete_permission(%Permission{} = permission) do
    repo().delete(permission)
  end

  def delete_permissions(role_id) do
    from(p in Permission, where: p.role_id == ^role_id)
    |> repo().delete_all()
  end

  @spec preload_user_roles(struct()) :: struct()
  def preload_user_roles(data), do: repo().preload(data, [:role, :user])

  def list_user_roles do
    repo().all(UserRole)
  end

  def list_user_role_by_user_id(user_id) do
    from(ur in UserRole, where: ur.user_id == ^user_id)
    |> repo().all
  end

  def get_user_role(user_role_id) do
    from(ur in UserRole, where: ur.id == ^user_role_id)
    |> repo().one
  end

  def get_user_role_by(user_id, role_id) do
    from(ur in UserRole, where: ur.role_id == ^role_id and ur.user_id == ^user_id)
    |> repo().one
  end

  def update_user_roles(role_id, role) do
    from(ur in UserRole,
      where: ur.role_id == ^role_id
    )
    |> repo().update_all(set: [role_id: role])
  end

  def get_user_roles_by_user_id(user_id) do
    from(ur in UserRole,
      where: ur.user_id == ^user_id,
      select: ur.role_id
    )
    |> repo().all
  end

  def create_user_role(attrs \\ %{}) do
    %UserRole{}
    |> UserRole.changeset(attrs)
    |> repo().insert()
  end

  #  @spec update_user_roles(list(), String.Chars) :: {integer(), nil | [term()]}
  #  def update_user_roles(user_roles, updated_role) do
  #    repo().update_all(user_roles, set: [role_is: ^updated_role])
  #  end

  def delete_user_role(%UserRole{} = user_role) do
    repo().delete(user_role)
  end

  def delete_user_roles(role_id) do
    from(u_r in UserRole, where: u_r.role_id == ^role_id)
    |> repo().delete_all()
  end

  @spec create(atom(), map()) :: {:ok, struct()} | {:error, struct()}
  def create(model, attrs \\ %{}) do
    struct(model)
    |> model.changeset(attrs)
    |> repo().insert()
  end

  @spec create_all(atom(), list()) :: {integer(), nil | [term()]}
  def create_all(model, attrs \\ []), do: struct(model) |> repo().insert_all(attrs)
end
