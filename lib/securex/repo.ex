defmodule SecureX.Repo do
  @moduledoc false
  # Dynamic Repo Of Current App
  def repo do
    :securex
    |> Application.fetch_env!(:repo)
  end
end
