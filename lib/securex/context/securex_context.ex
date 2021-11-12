defmodule SecureX.SecureXContext do
  @moduledoc false

  import Ecto.Query, warn: false
  alias SecureX.Repo

  alias SecureX.{Role, Permission, Resource, UserRole}

  @doc """
  Returns the list of roles.

  ## Examples

      iex> list_roles()
      [%Role{}, ...]

  """

  def list_roles do
    from(r in Role,
      order_by: [asc: r.id],
    ) |> Repo.all
  end

  def list_roles(offset, limit \\ 10) do
    from(r in Role,
      offset: ^offset,
      limit: ^limit,
      order_by: [asc: r.id],
    ) |> Repo.all
  end

  def list_roles_by(offset, limit \\ 10) do
    from(r in Role,
      join: p in Permission, on: p.role_id == r.id,
      offset: ^offset,
      limit: ^limit,
      order_by: [asc: r.id],
      select: %{
        permission: p.permission,
        resource: p.resource_id,
        role: r.id
      }
    ) |> Repo.all
  end

  @doc """
  Gets a single role.

  Raises `Ecto.NoResultsError` if the User role does not exist.

  ## Examples

      iex> get_role!(123)
      %Role{}

      iex> get_role!(456)
      ** (Ecto.NoResultsError)

  """
  def get(role_id) do
    from(r in Role,
      join: p in Permission, on: p.role_id == r.id,
      where: r.id == ^role_id,
      order_by: [asc: p.resource_id],
      select: %{
        id: r.id,
        name: r.name,
        permission: p.permission,
        resource: p.resource_id
      }
    )
    |> Repo.all
  end

  def get_roles_by(role_id) do
    role_id = role_id
              |> String.trim
              |> String.replace(" ", "_" )
              |> String.downcase
    from(r in Role, where: r.id == ^role_id)
    |> Repo.one
  end

  @doc """
  Creates a role.

  ## Examples

      iex> create_role(%{field: value})
      {:ok, %Role{}}

      iex> create_role(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_role(attrs \\ %{}) do
    %Role{}
    |> Role.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a role.

  ## Examples

      iex> update_role(role, %{field: new_value})
      {:ok, %Role{}}

      iex> update_role(role, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_role(%Role{} = role, attrs) do
    role
    |> Role.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a role.

  ## Examples

      iex> delete_role(role)
      {:ok, %Role{}}

      iex> delete_role(role)
      {:error, %Ecto.Changeset{}}

  """
  def delete_role(%Role{} = role) do
    Repo.delete(role)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking role changes.

  ## Examples

      iex> change_role(role)
      %Ecto.Changeset{data: %Role{}}

  """
  def change_role(%Role{} = role, attrs \\ %{}) do
    Role.changeset(role, attrs)
  end

  @doc """
  Returns the list of resources.

  ## Examples

      iex> list_resources()
      [%Resource{}, ...]

  """
  def list_resources do
    Repo.all(from(r in Resource, order_by: [asc: r.name]))
  end

  @doc """
  Gets a single resource.

  Raises `Ecto.NoResultsError` if the Resource does not exist.

  ## Examples

      iex> get_resource!(123)
      %Resource{}

      iex> get_resource!(456)
      ** (Ecto.NoResultsError)

  """

  def get_resource(res) do
    from(r in Resource, where: r.id == ^res)
    |> Repo.one
  end

  @doc """
  Creates a resource.

  ## Examples

      iex> create_resource(%{field: value})
      {:ok, %Resource{}}

      iex> create_resource(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_resource(attrs \\ %{}) do
    %Resource{}
    |> Resource.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a resource.

  ## Examples

      iex> update_resource(resource, %{field: new_value})
      {:ok, %Resource{}}

      iex> update_resource(resource, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_resource(%Resource{} = resource, attrs) do
    resource
    |> Resource.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a resource.

  ## Examples

      iex> delete_resource(resource)
      {:ok, %Resource{}}

      iex> delete_resource(resource)
      {:error, %Ecto.Changeset{}}

  """
  def delete_resource(%Resource{} = resource) do
    Repo.delete(resource)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking resource changes.

  ## Examples

      iex> change_resource(resource)
      %Ecto.Changeset{data: %Resource{}}

  """
  def change_resource(%Resource{} = resource, attrs \\ %{}) do
    Resource.changeset(resource, attrs)
  end

  @doc """
  Returns the list of permissions.

  ## Examples

      iex> list_permissions()
      [%Permission{}, ...]

  """
  def list_permissions(roles) do
    from(ru in Permission,
      join: r in Resource, on: ru.resource_id == r.id,
      where: ru.role_id in ^roles,
      select: %{
        permission: ru.permission,
        resource: ru.resource_id,
        role: ru.role_id
      }
    ) |> Repo.all
  end

  #  def list_permissions_by(role_ids) do
  #    from(ru in Permission,
  #      join: r in Resource, on: ru.resource_id == r.id,
  #      join: u in User, on: ru.user_id == ^user_id,
  #      distinct: ru.id,
  #      select: %{
  #        id: ru.id,
  #        resource: r.res,
  #        permission: ru.permission
  #      }
  #    )
  #    |> Repo.all
  #  end

  @doc """
  Gets a single permission.

  Raises `Ecto.NoResultsError` if the Permission does not exist.

  ## Examples

      iex> get_permission!(123)
      %Permission{}

      iex> get_permission!(456)
      ** (Ecto.NoResultsError)

  """


  def get(role_id) do
    from(ru in Permission, where: ru.role_id == ^role_id)
    |> Repo.all
  end
  def get(res_id, role_id) do
    from(ru in Permission,
      where: ru.resource_id == ^res_id,
      where: ru.role_id == ^role_id
    ) |> Repo.one
  end

  def get_permission_by(roles) do
    from(ru in Permission,
      join: r in Resource, on: ru.resource_id == r.id,
      where: ru.role_id in ^roles,
      select: %{
        permission: ru.permission,
        resource: ru.resource_id,
        role: ru.role_id
      }
    ) |> Repo.all
  end
  def get_permission_by(res_id, roles) do
    from(ru in Permission,
      where: ru.resource_id == ^res_id,
      where: ru.role_id in ^roles,
      order_by: [desc: ru.permission],
      limit: 1,
      select: %{
        permission: ru.permission,
        resource: ru.resource_id,
        role: ru.role_id
      }
    ) |> Repo.one
  end

  @doc """
  Creates a permission.

  ## Examples

      iex> create_permission(%{field: value})
      {:ok, %Permission{}}

      iex> create_permission(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_permission(attrs \\ %{}) do
    %Permission{}
    |> Permission.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a Permission.

  ## Examples

      iex> update_permission(permission, %{field: new_value})
      {:ok, %Permission{}}

      iex> update_permission(permission, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_permission(%Permission{} = permission, attrs) do
    permission
    |> Permission.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Permission.

  ## Examples

      iex> delete_permission(permission)
      {:ok, %Permission{}}

      iex> delete_permission(permission)
      {:error, %Ecto.Changeset{}}

  """
  def delete_permission(%Permission{} = permission) do
    Repo.delete(permission)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking permission changes.

  ## Examples

      iex> change_permission(permission)
      %Ecto.Changeset{data: %Permission{}}

  """
  def change_permission(%Permission{} = permission, attrs \\ %{}) do
    Permission.changeset(permission, attrs)
  end

  @doc """
  Returns the list of user_roles.

  ## Examples

      iex> list_user_roles()
      [%UserRole{}, ...]

  """
  def list_user_roles do
    Repo.all(UserRole)
  end

  @doc """
  Gets a single user_role.

  Raises `Ecto.NoResultsError` if the User role does not exist.

  ## Examples

      iex> get_user_role!(123)
      %UserRole{}

      iex> get_user_role!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user_roles_by(%{role_id: role_id}) do
    from(ur in UserRole,
      where: ur.role_id == ^role_id,
    )
    |> Repo.all
  end
  def get_user_roles_by(user_id) do
    from(ur in UserRole,
      where: ur.user_id == ^user_id,
      select: ur.role_id
    )
    |> Repo.all
  end

  @doc """
  Creates a user_role.

  ## Examples

      iex> create_user_role(%{field: value})
      {:ok, %UserRole{}}

      iex> create_user_role(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_role(attrs \\ %{}) do
    %UserRole{}
    |> UserRole.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user_role.

  ## Examples

      iex> update_user_role(user_role, %{field: new_value})
      {:ok, %UserRole{}}

      iex> update_user_role(user_role, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_role(%UserRole{} = user_role, attrs) do
    user_role
    |> UserRole.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user_role.

  ## Examples

      iex> delete_user_role(user_role)
      {:ok, %UserRole{}}

      iex> delete_user_role(user_role)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user_role(%UserRole{} = user_role) do
    Repo.delete(user_role)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_role changes.

  ## Examples

      iex> change_user_role(user_role)
      %Ecto.Changeset{data: %UserRole{}}

  """
  def change_user_role(%UserRole{} = user_role, attrs \\ %{}) do
    UserRole.changeset(user_role, attrs)
  end
end
