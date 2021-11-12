defmodule SecureXWeb.ResourceController do
  @moduledoc false

  use SecureXWeb, :controller
  alias SecureX.SecureXContext, as: Context

  @doc """
  Create an resource,
  example: create(%{"id" => id, "name" => name})
  """
  @spec create(map()) :: struct()
  def create(%{"id" => _} = params)do
    Context.create_resource(params)
  end
  def create(_), do: {:error, :bad_input}
end
