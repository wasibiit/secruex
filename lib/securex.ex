defmodule SecureX do
  alias SecureXWeb.{ ResourceController, RoleController }

  @moduledoc """

  """
  def add_role(params) do
    case RoleController.create(params) do
      {:error, error} -> {:error, error}
      {:ok, role} -> {:ok, role}
    end
  end
end