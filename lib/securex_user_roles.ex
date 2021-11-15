defmodule SecureX.UserRoles do
  alias SecureXWeb.{ UserRoleController }

  @moduledoc """

  """

  @doc """
  Add an UserRole. You can send either `Atom Map` or `String Map` to add UserRole.

  ## Examples

      iex> create(%{"user_id" => 1, "role_id" => "super_admin"})
      %UserRole{
        id: 1,
        user_id: 1,
        role_id: "super_admin"
      }
  """
  @spec add(map()) :: struct()
  def add(params) do
    case PermissionController.create(params) do
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
  @spec delete(map()) :: struct()
  def delete(params) do
    case PermissionController.delete(params) do
      {:error, error} -> {:error, error}
      {:ok, role} -> {:ok, role}
    end
  end
end