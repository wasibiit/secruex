defmodule SecureX.MixProject do
  use Mix.Project

  def project do
    [
      app: :securex,
      version: "1.0.4",
      maintainers: ["Wasi Ur Rahman"],
      licenses: ["Apache 2.0"],
      description:
        "SecureX is Role Based Access Control(RBAC) and Access Control List (ACL) to handle User Roles And Permissions.",
      links: %{"GitHub" => "https://github.com/wasitanbits/secruex"},
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      name: "SecureX",
      source_url: "https://github.com/wasitanbits/secruex",
      homepage_url: "https://github.com/wasitanbits/secruex",
      docs: [
        # The main page in the docs
        main: "SecureX",
        extras: ["README.md"],
        api_reference: false
      ]
    ]
  end

  defp description do
    """
    SecureX is Role Based Access Control(RBAC) and Access Control List (ACL) to handle User Roles And Permissions.
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md"],
      maintainers: ["Wasi Ur Rahman"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/wasitanbits/secruex"},
      description:
        "SecureX is Role Based Access Control(RBAC) and Access Control List (ACL) to handle User Roles And Permissions."
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {SecureX.Application, []},
      extra_applications: [:logger, :runtime_tools, :scrivener_ecto]
    ]
  end

  defp deps do
    [
      [
        {:phoenix, "~> 1.6"},
        {:ecto_sql, "~> 3.7"},
        {:sage, "~> 0.6.1"},
        {:scrivener_ecto, "~> 2.7"}
      ],
      [
        {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
        {:credo, "~> 1.6.4", only: [:dev, :test], runtime: false}
      ]
    ]
    |> Enum.concat()
  end
end
