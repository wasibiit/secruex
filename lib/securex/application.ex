defmodule SecureX.Application do
  @moduledoc false

  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
#      supervisor(SecureX.Repo, []),
      # Start the endpoint when the application starts
      # Start your own worker by calling: SecureX.Worker.start_link(arg1, arg2, arg3)
      # worker(SecureX.Worker, [arg1, arg2, arg3]),
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SecureX.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
