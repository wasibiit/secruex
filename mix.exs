defmodule SecureX.MixProject do
  use Mix.Project

  def project do
    [
      app: :securex,
      version: "0.1.0",
      elixir: "~> 1.12 ",
      maintainers: ["Wasi Ur Rahman"],
      licenses: ["Apache 2.0"],
      description: "SecureX is Role Based Access Control(RBAC). It will handle user roles and permissions.",
      links: %{"GitHub" => "https://github.com/DevWasi/secruex"},
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      aliases: aliases(),
      deps: deps(),
      name: "SecureX",
      source_url: "https://github.com/DevWasi/secruex",
      homepage_url: "https://github.com/DevWasi/secruex",
      docs: [
        main: "SecureX", # The main page in the docs
        extras: ["README.md"],
        api_reference: false
      ]
    ]
  end

  defp description do
    """
    SecureX is Role Based Access Control(RBAC). It will handle user roles and permissions.
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md"],
      maintainers: ["Wasi Ur Rahman"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/DevWasi/secruex"},
      description: "SecureX is Role Based Access Control(RBAC). It will handle user roles and permissions."
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {SecureX.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto_sql, "~> 3.7"},
      {:ecto, "~> 3.7"},
      {:cowboy, "~> 2.9"},
      {:plug_cowboy, "~> 2.2"},
      {:phoenix, "~> 1.5"},
      {:phoenix_html, "~> 2.14.1"},
      {:postgrex, ">= 0.0.0"},
      {:gettext, "~> 0.18.2"},
      {:jason, "~> 1.2"},
      {:dialyxir, "~> 1.1"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
