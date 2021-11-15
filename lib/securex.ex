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
  You are Now Up and Running!!!

  ## Guide

  You can also use SecureX as a Middleware

  ## Middlewares
  In RestApi or GraphiQL all you have to do, add a `Plug`.

  ## Examples
  ```elixir
   #lib/plugs/securex_plug.ex

    defmodule MyApp.Plugs.SecureXPlug do
      @behaviour Plug

      import Plug.Conn

      def init(default), do: default

      def call(conn, _) do
        with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
            {:ok, claims} <- MyApp.Auth.Guardian.decode_and_verify(token),
            {:ok, user} <- MyApp.Auth.Guardian.resource_from_claims(claims),
            {:ok, %Plug.Conn{}} <- check_permissions(conn, user) do
      conn
    else
      {:error, error} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(403, Jason.encode!(%{errors: error}))
        |> Plug.Conn.halt()
      _ ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(403, Jason.encode!(%{errors: ["Permission Denied"]}))
        |> Plug.Conn.halt()
    end
  end

  defp check_permissions(%{body_params: %{"resource" => res, "permission" => permission}} = conn, %{id: user_id}) do
    case SecureX.has_access?(user_id, res, permission) do
        false -> {:error, false}
        true -> {:ok, conn}
      end
  end
  defp check_permissions(_, _), do: {:error, ["Invalid Request"]}
  end
  ```

   ## Permissions
  Valid inputs for permissions are "POST","GET","PUT" ,"DELETE","read","write","delete","edit" as well.
  Permissions have downward flow. i.e if you have defined permissions for a higher operation,
  It automatically assigns them permissions for lower operations.
  like "edit" grants permissions for all operations. their hierarchy is in this order.

  ```
    "read" < "write" < "delete" < "edit"
    "GET" < "POST" < "DELETE" < "PUT"
    1 < 2 < 3 < 4
  ```
  """

  @doc """
  Check if user has access.

  ## Examples

      iex> has_access?(1, "users", "write")
      true

      iex> has_access?(1, "Gibberish", "bad_input")
      false
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
      "GET" || "get" || "READ" || "read" || "1" || 1 || "POST" || "post" || "write" || "WRITE" || "2" || 2 -> 2
      "GET" || "get" || "READ" || "read" || "1" || 1 || "POST" || "post" || "write" || "WRITE" || "2" || 2 || "UPDATE" || "update" || "edit" || "EDIT" || "3" || 3 -> 3
      "GET" || "get" || "READ" || "read" || "1" || 1 || "POST" || "post" || "write" || "WRITE" || "2" || 2 || "UPDATE" || "update" || "edit" || "EDIT" || "3" || 3 || "DELETE" || "delete" || "4" || 4 -> 4
      _ -> nil
    end
  end
end