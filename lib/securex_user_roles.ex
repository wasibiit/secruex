defmodule SecureX.UserRoles do
  alias SecureXWeb.{UserRoleController}

  @moduledoc """
  Contains CRUD For UserRoles.
  """

  @doc """
  Get list Of UserRoles by `user_id`.

  ## Examples

      iex> get(%{"user_id" => 0})
      {:error, :no_user_roles_found}

      iex> get(%{"user_id" => 1})
      {:ok,
          [
            %UserRole{
              role_id: "admin",
              user_id: 1
            },
            %UserRole{
              role_id: "super_admin",
              user_id: 1
            }
          ]
      }
  """
  @spec get(map()) :: tuple()
  def get(params), do: UserRoleController.get(params)

  @doc """
  Add an UserRole. You can send either `Atom Map` or `String Map` to add an UserRole.

  ## Examples

      iex> create(%{"user_id" => 1, "role_id" => "super_admin"})
      %UserRole{
        id: 1,
        user_id: 1,
        role_id: "super_admin"
      }
  """
  @spec add(map()) :: tuple()
  def add(params) do
    case UserRoleController.create(params) do
      {:error, error} -> {:error, error}
      {:ok, role} -> {:ok, role}
    end
  end

  @doc """
  Delete an UserRole.

  ## Examples

      iex> delete(%{"id" => 1)
      %Permission{
        id: 1,
        user_id: 1,
        role_id: "admin"
      }
  """
  @spec delete(map()) :: tuple()
  def delete(params) do
    case UserRoleController.delete(params) do
      {:error, error} -> {:error, error}
      {:ok, role} -> {:ok, role}
    end
  end
end
