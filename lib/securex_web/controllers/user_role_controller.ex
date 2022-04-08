defmodule SecureXWeb.UserRoleController do
  @moduledoc false

  use SecureXWeb, :controller
  alias SecureX.Context

  @doc """
  Get list of UserRoles by `user_id`,

  ## Examples

      iex> get(%{"user_id" => 1})
      ["owner", "admin", ...]

  """
  @spec get(map()) :: tuple()
  def get(params) when params !== %{} do
    case params do
      %{user_id: user_id} -> get_user_role(user_id)
      %{"user_id" => user_id} -> get_user_role(user_id)
      _ -> {:error, :bad_input}
    end
  end

  def get(_), do: {:error, :bad_input}

  defp get_user_role(params) do
    case Context.get_user_roles_by_user_id(params) do
      nil -> {:error, :no_user_roles_found}
      roles -> {:ok, roles}
    end
  end

  @doc """
  Create an UserRole,

  ## Examples

      iex> create(%{"user_id" => 1, "role_id" => "super_admin"})
      %UserRole{
        id: 1,
        user_id: 1,
        role_id: "super_admin"
      }
  """
  @spec create(map()) :: tuple()
  def create(params) when params !== %{} do
    case params do
      %{user_id: _, role_id: _} ->
        create_user_role(params)

      %{"user_id" => _, "role_id" => _} ->
        params = keys_to_atoms(params)
        create_user_role(params)

      _ ->
        {:error, :bad_input}
    end
  end

  def create(_), do: {:error, :bad_input}

  defp create_user_role(params) do
    with nil <- Context.get_user_role_by(params.user_id, params.role_id),
         {:ok, user_role} <- Context.create_user_role(params) do
      {:ok, user_role}
    else
      %{__struct__: _} -> {:error, :alrady_exist}
      {:error, error} -> {:error, error}
    end
  end

  @doc """
  Delete an User Role,

  ## Examples

      iex> delete(%{"id" => 1)
      %Permission{
        id: 1,
        user_id: 1,
        role_id: "admin"
      }
  """
  @spec delete(map()) :: tuple()
  def delete(params) when params !== %{} do
    case params do
      %{id: user_role_id} -> delete_user_role(user_role_id)
      %{"id" => user_role_id} -> delete_user_role(user_role_id)
      _ -> {:error, :bad_input}
    end
  end

  def delete(_), do: {:error, :bad_input}

  defp delete_user_role(user_role_id) do
    with %{__struct__: _} = user_role <- Context.get_user_role(user_role_id),
         {:ok, user_role} <- Context.delete_user_role(user_role) do
      {:ok, user_role}
    else
      nil -> {:error, :doesnt_exist}
      {:error, error} -> {:error, error}
    end
  end
end
