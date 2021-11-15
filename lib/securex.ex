defmodule SecureX do
#  alias SecureXWeb.{ ResourceController, RoleController }

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

  The Migrations now added to your project. It will ask you if you want to migrate it as well.
  Do you want to run this migration? `y/n`, Press `y` if you want to Migrate.
  ```elixir
  iex> "Do you want to run this migration?" #y
  iex> mix ecto.migrate
  ```

  """
end