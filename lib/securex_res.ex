defmodule SecureX.Res do
  alias SecureXWeb.{ResourceController}

  @moduledoc """
  Contains CRUD For Resources.
  """

  @doc """
  Get list of Resources.

  ## Examples

      iex> list()
      [
      %Resource{
        id: "person_farm",
        name: "Persons Farm"
      },
      %Resource{
        id: "users",
        name: "Users"
      }
      ]
  """
  @spec list() :: tuple()
  def list() do
    case ResourceController.list_resources() do
      [] -> {:error, :no_resources_found}
      res -> {:ok, res}
    end
  end

  @doc """
  Get a Resource.

  ## Examples

      iex> get(%{"res" => "person_farm"})
      %Resource{
        id: "person_farm",
        name: "Persons Farm"
      }
  """
  @spec get(map()) :: tuple()
  def get(params) do
    case ResourceController.get(params) do
      {:error, error} -> {:error, error}
      {:ok, res} -> {:ok, res}
    end
  end

  @doc """
  Add a Resource. You can send either `Atom Map` or `String Map` to add a Resource.

  ## Examples

      iex> add(%{"res" => "Person Farm"})
      %Resource{
        id: "person_farm",
        name: "Persons Farm"
      }
  """
  @spec add(map()) :: tuple()
  def add(params) do
    case ResourceController.create(params) do
      {:error, error} -> {:error, error}
      {:ok, role} -> {:ok, role}
    end
  end

  @doc """
  Update a Resource. You can update any resource along with its permissions.
  You can send either `Atom Map` or `String Map` to update a Role. It will automatically
  update `resource_id` in `Permissions` table.

  ## Examples

      iex> update(%{"id" => "person_farm", "res" => "Person Organization"})
      %Resource{
        id: "person_organization",
        name: "Person Organization",
        permissions: :successfully_updated_permissions
      }

  """
  @spec update(map()) :: tuple()
  def update(params) do
    case ResourceController.update(params) do
      {:error, error} -> {:error, error}
      {:ok, role} -> {:ok, role}
    end
  end

  @doc """
  Delete a Resource. All `Permissions` will be removed against this resource.

  ## Examples

      iex> delete(%{"id" => "person_organization")
      %Resource{
        id: "person_organization",
        name: "Person Organization",
        permissions: :successfully_removed_permissions
      }
  """
  @spec delete(map()) :: tuple()
  def delete(params) do
    case ResourceController.delete(params) do
      {:error, error} -> {:error, error}
      {:ok, role} -> {:ok, role}
    end
  end
end
