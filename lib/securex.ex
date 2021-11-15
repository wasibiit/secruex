defmodule SecureX do
  alias SecureX.SecureXContext, as: Context

  @moduledoc """
  SecureX is an Elixir Library to handle your RBAC (Role Based Access Control).

  It has 4 basic modules, `SecureX.Roles`, `SecureX.Res`, `SecureX.Permissions` and `SecureX.UserRoles`.
  All Modules have CRUD to maintain your RBAC.
  `SecureX` Module has validation for user.

  ## Installation

  If installing from Hex, use the latest version from there:
  ```elixir
  # mix.ex

  def deps do
  [
    {:securex, "~> 0.1.0"}
  ]
  end
  ```
  Now You need to add configuration for `securex` in your `config/config.ex`
  You need to add Your Repo and User Schema in config.
  ```elixir
  # config/config.exs

  config :securex, repo: MyApp.Repo,
   schema: MyApp.Schema.User
  ```
  SecureX comes with built-in support for apps. Just create migrations with `mix secure_x.gen.migrate`.
  ```elixir
  iex> mix secure_x.gen.migrate
  * creating priv/repo/migrations
  * creating priv/repo/migrations/20211112222439_create_table_roles.exs
  * creating priv/repo/migrations/20211112222439_create_table_resources.exs
  * creating priv/repo/migrations/20211112222439_create_table_permissions.exs
  * creating priv/repo/migrations/20211112222439_create_table_user_roles.exs
  ```
  The Migrations added to your project.
  ```elixir
  iex> "Do you want to run this migration?"
  iex> mix ecto.migrate
  ```
  """

  @doc """

  """
  @spec has_access?(any(), string(), any()) :: boolean()
  def has_access?(user_id, res_id, permission) when !is_nil(user_id) and !is_nil(res_id) and !is_nil(permission) do
    case translate_permission(permission) do
      nil -> false
      permission ->
        case Context.get_resource(res_id) do
          nil -> false
          %{id: res_id} ->
            roles = Context.get_user_roles_by_user_id(user_id)
            case Context.get_permission_by(res_id, roles) do
              nil -> false
              %{permission: per} ->
                cond do
                  permission == 1 and per == 1 -> true
                  permission == 2 and per == 2 -> true
                  permission == 3 and per == 3 -> true
                  permission == 4 and per == 4 -> true
                  true -> false
                end
            end
        end
    end
  end

  defp translate_permission (permission) do
    case permission do
      "GET" || "get" || "READ" || "read" || "1" || 1 -> 1
      "POST" || "post" || "write" || "WRITE" || "2" || 2 -> 2
      "UPDATE" || "update" || "edit" || "EDIT" || "3" || 3 -> 3
      "DELETE" || "delete" || "4" || 4 -> 4
      _ -> nil
    end
  end
end