defmodule SecureXWeb.PermissionController do
  @moduledoc false

  use SecureXWeb, :controller
  alias SecureX.Context

  @doc """
  Get list of Permissions By Roles,

  ## Examples

      iex> list_permissions(["owner", "super_admin"])
      [
      ...
      %{ permission: 4, resource_id: "users", role_id: "admin"},
      ...
      %{ permission: 4, resource_id: "person_form", role_id: "super_admin"},
      ...
    ]
  """
  @spec list_permissions(list()) :: nonempty_list()
  def list_permissions(params) when params !== [] do
    Context.list_permissions(params)
  end

  def list_permissions(_), do: {:error, :bad_input}

  @doc """
  Create a Permission,

  ## Examples

      iex> create(%{"permission" => -1, "resource_id" => "users", "role_id" => "super_admin"})
      %Permission{
        id: 1,
        permission: -1,
        resource_id: "users",
        role_id: "super_admin"
      }
  """
  @spec create(map()) :: tuple()
  def create(params) when params !== %{} do
    case params do
      %{resource_id: _, role_id: _} ->
        create_per(params)

      %{"resource_id" => _, "role_id" => _} ->
        params = keys_to_atoms(params)
        create_per(params)

      _ ->
        {:error, :bad_input}
    end
  end

  def create(_), do: {:error, :bad_input}

  defp create_per(params) do
    with nil <- Context.get_permission(params.resource_id, params.role_id),
         {:ok, per} <- Context.create_permission(params) do
      {:ok, per}
    else
      %{__struct__: _} -> {:error, :alrady_exist}
      {:error, error} -> {:error, error}
    end
  end

  @doc """
  Update a Permission,

  ## Examples

      iex> update(%{"id" => "1", "resource_id" => "users", "permission" => 4, "role_id" => "admin"})
      %Permission{
        id: 1,
        permission: 4,
        resource_id: "users",
        role_id: "admin"
      }
  """
  @spec update(map()) :: tuple()
  def update(params) when params !== %{} do
    case params do
      %{id: per_id} ->
        update_per(per_id, params)

      %{"id" => per_id} ->
        params = keys_to_atoms(params)
        update_per(per_id, params)

      _ ->
        {:error, :bad_input}
    end
  end

  def update(_), do: {:error, :bad_input}

  defp update_per(per_id, params) do
    with %{__struct__: _} = per <- Context.get_permission(per_id),
         {:ok, new_per} <- Context.update_permission(per, Map.delete(params, :id)) do
      {:ok, new_per}
    else
      nil -> {:error, :alrady_exist}
      {:error, error} -> {:error, error}
    end
  end

  @doc """
  Delete a Permission,

  ## Examples

      iex> delete(%{"id" => 1)
      %Permission{
        id: 1,
        permission: 4,
        resource_id: "users",
        role_id: "admin"
      }
  """
  @spec delete(map()) :: tuple()
  def delete(params) when params !== %{} do
    case params do
      %{id: per_id} -> delete_per(per_id)
      %{"id" => per_id} -> delete_per(per_id)
      _ -> {:error, :bad_input}
    end
  end

  def delete(_), do: {:error, :bad_input}

  defp delete_per(per_id) do
    with %{__struct__: _} = per <- Context.get_permission(per_id),
         {:ok, per} <- Context.delete_permission(per) do
      {:ok, per}
    else
      nil -> {:error, :doesnt_exist}
      {:error, error} -> {:error, error}
    end
  end
end
