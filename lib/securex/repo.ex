defmodule SecureX.Repo do
  @moduledoc false

  def repo do
    :securex
    |> Application.fetch_env!(SecureX.Repo)
    |> Keyword.fetch!(:repo)
  end
  @doc """
  Dynamically loads the repository url from the
  DATABASE_URL environment variable.
  """
  def init(_, opts) do
    {:ok, Keyword.put(opts, :url, System.get_env("DATABASE_URL"))}
  end
end
