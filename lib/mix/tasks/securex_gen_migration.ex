if Code.ensure_loaded?(Ecto) do
  defmodule Mix.Tasks.Securex.Gen.Migration do
    @moduledoc "The SecureX mix task to create migrations into your project `priv/repo/migrations` folder"
    use Mix.Task

    import Macro, only: [camelize: 1, underscore: 1]
    import Mix.{Generator, Ecto}
    import SecureX.Migration

    def run(args) do
      repos = parse_repo(args)

      Enum.each(repos, fn repo ->
        ensure_repo(repo, args)
        path = Path.relative_to(migrations_path(repo), Mix.Project.app_path())
        create_directory(path)

        migrations = [
          role: "create_table_roles",
          res: "create_table_resources",
          permission: "create_table_permission",
          user_roles: "create_table_user_roles"
        ]

        Enum.reduce(migrations, 1, fn {key, value}, acc ->
          time = timestamp(acc)

          content =
            [mod: Module.concat([repo, Migrations, camelize(value)])]
            |> (fn f -> f ++ [check: key] end).()
            |> migration_template
            |> format_string!

          Path.join(path, "#{time}_#{underscore(value)}.exs")
          |> create_file(content)

          acc + 1
        end)
      end)
    end

    defp timestamp(acc) do
      {{y, m, d}, {hh, mm, ss}} = :calendar.universal_time()
      "#{y}#{pad(m)}#{pad(d)}#{pad(hh)}#{pad(mm)}#{pad(ss + acc)}"
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
                add :id, :string, null: false, primary_key: true, unique: true
                add :name, :string

                timestamps()
              end
            end
        <% :res ->  %>
            def change do
              create table(:resources, primary_key: false) do
                add :id, :string, primary_key: true
                add :name, :string

                timestamps()
              end
            end
        <% :permission ->  %>
            <% primary_id_type = Application.get_env(:securex, :type) == :binary_id  %>
        
            def change do
              create table(:permissions, primary_key: <%= !primary_id_type %>) do
                <%= if primary_id_type do %>
                  add :id, :string, primary_key: true
                <% end %>
                
                add :permission, :integer
                add :role_id, references(:roles, on_delete: :nothing, type: :string)
                add :resource_id, references(:resources, on_delete: :nothing, type: :string)

                timestamps()
              end
              create unique_index(:permissions, [:role_id, :resource_id])
            end
        <% :user_roles ->  %>
            <% primary_id_type = Application.get_env(:securex, :type) == :binary_id  %>
            
            def change do
              create table(:user_roles, primary_key: <%= !primary_id_type %>) do
               <%= if primary_id_type do %>
                  add :id, :string, primary_key: true
                <% end %>
                
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
