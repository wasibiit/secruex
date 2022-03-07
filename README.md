[![CircleCI](https://circleci.com/github/wasitanbits/secruex.svg?style=svg)](https://app.circleci.com/pipelines/github/wasitanbits/secruex?branch=master)
[![License](https://img.shields.io/github/license/wasitanbits/secruex)](https://img.shields.io/github/license/wasitanbits/secruex)
[![License](https://img.shields.io/hexpm/dt/securex.svg)](https://img.shields.io/hexpm/dt/securex.svg)

# SecureX

SecureX (An Advancement To ACL) is Role Based Access Control(RBAC) and Access Control List (ACL) to handle "User Roles And Permissions".
You can handle all list of permissions attached to a specific object for certain users or give limited or full Access to specific
module.

It has 4 basic modules, `SecureX.Roles`, `SecureX.Res`, `SecureX.Permissions` and `SecureX.UserRoles`.
All Modules have CRUD to maintain your RBAC.
`SecureX` Module has validation for user.

## Installation

If installing from Hex, use the latest version from there:
  ```elixir
  # mix.ex

  def deps do
    [
      {:securex, "~> 1.0.0"}
    ]
  end
  ```
Now You need to add configuration for `securex` in your `config/config.ex`
You need to add Your Repo and User Schema in config. 
If you are using `binary_id` type for your project default as `@primary_keys`. You can pass `type: :binary_id`.
  ```elixir
  # config/config.exs

  config :securex, repo: MyApp.Repo, #required
   schema: MyApp.Schema.User, #required
   type: :binary_id #optional
  ```
SecureX comes with built-in support for apps. Just create migrations with `mix securex.gen.migration`.
  ```elixir
  iex> mix securex.gen.migration
  * creating priv/repo/migrations
  * creating priv/repo/migrations/20211112222439_create_table_roles.exs
  * creating priv/repo/migrations/20211112222440_create_table_resources.exs
  * creating priv/repo/migrations/20211112222441_create_table_permissions.exs
  * creating priv/repo/migrations/20211112222442_create_table_user_roles.exs
  ```
The Migrations added to your project.
  ```elixir
  iex> "Do you want to run this migration?"
  iex> mix ecto.migrate
  ```
You are Now Up and Running!!!

## Guide

You can also use SecureX as a Middleware.

Valid inputs for permissions are "POST", "GET", "PUT", "DELETE", "read", "write", "delete" and "edit".
Permissions have downward flow. i.e if you have defined permissions for a higher operation,
It automatically assigns them permissions for lower operations.
like "edit" grants permissions for all operations. their hierarchy is in this order.

  ```
    "read" < "write" < "delete" < "edit"
    "GET" < "POST" < "DELETE" < "PUT"
    1 < 2 < 3 < 4
  ```

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

  defp check_permissions(%{method: method, path_info: path_info} = conn, %{id: user_id}) do
    res = List.last(path_info)
    case SecureX.has_access?(user_id, res, method) do
      false -> {:error, false}
      true -> {:ok, conn}
    end
  end
  defp check_permissions(_, _), do: {:error, ["Invalid Request"]}
  end
  ```
You are all set. 
Please let us know about and open issue on https://github.com/DevWasi/secruex/issues
Looking Forward to it. 

Happy Coding !!!!!
