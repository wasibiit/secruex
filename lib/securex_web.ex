defmodule SecureXWeb do
  @moduledoc false

  @spec controller :: {:__block__, [], [{:import, [...], [...]} | {:use, [...], [...]}, ...]}
  def controller do
    quote do
      import Sage
      import SecureX.Helper
      import Macro, only: [camelize: 1, underscore: 1]
      use Phoenix.Controller, namespace: SecureXWeb
    end
  end

  @spec __using__(atom) :: any
  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
