if Code.ensure_loaded?(Ecto) do
  defmodule Mix.Tasks.SecureX.Gen.Migrate do
    @moduledoc "The SecureX mix task to create migrations into your project `priv/repo/migrations` folder"
    use Mix.Task

    import Macro, only: [camelize: 1, underscore: 1]
    import Mix.Generator
    import Mix.Ecto
    import SecureX.Migration

    def run(args) do
      repos = parse_repo(args)
      Enum.each(repos, fn repo ->
        ensure_repo(repo, args)
        path = Path.relative_to(migrations_path(repo), Mix.Project.app_path())
        create_directory(path)
        migrations = [role: "create_table_roles", res: "create_table_resources", permission: "create_table_permission", user_roles: "create_table_user_roles"]

        Enum.each(migrations, fn {key, value} ->
          content =
            [mod: Module.concat([repo, Migrations, camelize(value)])]
            |> (fn f -> f ++ [check: key] end).()
            |> migration_template
            |> format_string!
          file = Path.join(path, "#{timestamp()}_#{underscore(value)}.exs")
          |> create_file(content)
          if open?(file) and Mix.shell().yes?("Do you want to run this migration?") do
            Mix.Task.run("ecto.migrate", [repo])
          end
        end)
      end
      )
    end

    defp timestamp do
      {{y, m, d}, {hh, mm, ss}} = :calendar.universal_time()
      "#{y}#{pad(m)}#{pad(d)}#{pad(hh)}#{pad(mm)}#{pad(ss)}"
    end

    defp pad(i) when i < 10, do: <<?0, ?0 + i>>
    defp pad(i), do: to_string(i)

    embed_template(
      :migration,
      """
      defmodule <%= inspect @mod %> do
        use Ecto.Migration
        <%= case @check do %>
          <% :role ->  %>
            def change do
              create table(:roles, primary_key: false) do
                add :role, :string, null: false, primary_key: true, unique: true
                add :name, :string

                timestamps()
              end
              create unique_index(:roles, [:id])
            end
        <% :res ->  %>
            def change do
              create table(:resources, primary_key: false) do
                add :id, :string, primary_key: true
                add :name, :string

                timestamps()
              end
              create unique_index(:resources, [:id])
            end
        <% :permission ->  %>
            def change do
              create table(:permissions) do
                add :permission, :integer
                add :role_id, references(:roles, on_delete: :nothing, type: :string)
                add :resource_id, references(:resources, on_delete: :nothing, type: :string)

                timestamps()
              end
              create unique_index(:permissions, [:role_id, :resource_id])
            end
        <% :user_roles ->  %>
            def change do
              create table(:user_roles) do
                add :role_id, references(:roles, on_delete: :nothing, type: :string)
                add :user_id, references(:users, on_delete: :nothing)

                timestamps()
              end
              create unique_index(:user_roles, [:user_id, :role_id])
            end
      <% end %>
      end
      """
    )
  end
end