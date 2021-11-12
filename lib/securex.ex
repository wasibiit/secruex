defmodule SecureX do
  alias SecureXWeb.{ ResourceController }
  @doc """
  Welcome.
  """
  def add_resource(params) do
    ResourceController.create(params)
  end
end