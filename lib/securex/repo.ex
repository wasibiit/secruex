defmodule SecureX.Repo do
  @moduledoc false
  use Scrivener, page_size: 10

  # Dynamic Repo Of Current App
  def repo do
    :securex
    |> Application.fetch_env!(:repo)

  end
end
