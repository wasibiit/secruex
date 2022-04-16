defmodule SecureX.Permissions do
  alias SecureXWeb.{PermissionController}

  @moduledoc """
  Contains CRUD For Permissions.
  """

  @doc """
  Get list of Permissions by User Roles.
    List/1 is without pagination,
    List/2 & List/3 is with pagination.

  ## Examples

      iex> list([], 1)
      {:error, :bad_input}

      iex> list([])
      {:error, :bad_input}

      iex> list(["owner", "super_admin"], 1)
      {:ok,
        %Scrivener.Page{
          entries: [
            %{permission: 4, resource_id: "roles", role_id: "owner"},
            %{permission: 4, resource_id: "users", role_id: "owner"},
            %{permission: 4, resource_id: "stock_types", role_id: "owner"},
            %{permission: 4, resource_id: "sales", role_id: "owner"},
            %{permission: 4, resource_id: "stocks", role_id: "owner"},
            %{permission: 4, resource_id: "providers", role_id: "owner"},
            %{permission: 4, resource_id: "fuel_dispensers", role_id: "owner"},
            %{permission: 4, resource_id: "employees", role_id: "owner"},
            %{permission: 4, resource_id: "customers", role_id: "owner"},
            %{permission: 4, resource_id: "stock_stats", role_id: "owner"}
          ],
        page_number: 1,
        page_size: 10,
        total_entries: 22,
        total_pages: 3
      }
    }

    iex> list(["owner", "super_admin"])
      [
      %{ permission: 4, resource_id: "users", role_id: "admin"},
      %{ permission: 4, resource_id: "person_form", role_id: "super_admin"}
     ]
  """
  @spec list(list(), number(), number()) :: tuple()
  def list(list, page \\ nil, page_size \\ 10),
    do: PermissionController.list_permissions(list, page, page_size)

  @doc """
  Add a Permission. You can send either `Atom Map` or `String Map` to add a Permission.

  ## Examples

      iex> add(%{"permission" => -1, "resource_id" => "users", "role_id" => "super_admin"})
      %Permission{
        id: 1,
        permission: -1,
        resource_id: "users",
        role_id: "super_admin"
      }
  """
  @spec add(map()) :: tuple()
  def add(params) do
    case PermissionController.create(params) do
      {:error, error} -> {:error, error}
      {:ok, role} -> {:ok, role}
    end
  end

  @doc """
  Update a Permission. You can send either `Atom Map` or `String Map` to update a Permission.

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
  def update(params) do
    case PermissionController.update(params) do
      {:error, error} -> {:error, error}
      {:ok, role} -> {:ok, role}
    end
  end

  @doc """
  Delete a Permission.

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
  def delete(params) do
    case PermissionController.delete(params) do
      {:error, error} -> {:error, error}
      {:ok, role} -> {:ok, role}
    end
  end
end
