defmodule SecureXWeb.Router do
  @moduledoc false

  use SecureXWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", SecureXWeb do
    pipe_through :api

  end

end
