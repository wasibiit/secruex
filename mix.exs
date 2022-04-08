defmodule SecureX.MixProject do
  use Mix.Project

  def project do
    [
      app: :securex,
      version: "1.0.0",
      maintainers: ["Wasi Ur Rahman"],
      licenses: ["Apache 2.0"],
      description:
        "SecureX is Role Based Access Control(RBAC) and Access Control List (ACL) to handle User Roles And Permissions.",
      links: %{"GitHub" => "https://github.com/DevWasi/secruex"},
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      name: "SecureX",
      source_url: "https://github.com/DevWasi/secruex",
      homepage_url: "https://github.com/DevWasi/secruex",
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
      links: %{"GitHub" => "https://github.com/DevWasi/secruex"},
      description:
        "SecureX is Role Based Access Control(RBAC) and Access Control List (ACL) to handle User Roles And Permissions."
    ]
  end
  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {SecureX.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end
  defp deps do
    [
     [
       {:gettext, "~> 0.19.1"},
       {:phoenix, "~> 1.6"},
       {:jason, "~> 1.3"},
       {:ecto_sql, "~> 3.7"},
       {:sage, "~> 0.6.1"}
     ],
      [
        {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
        {:credo, "~> 1.6.4", only: [:dev, :test], runtime: false}
      ]
    ]
    |> Enum.concat()
  end
end
