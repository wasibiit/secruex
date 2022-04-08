defmodule SecureX.Schema do
  @moduledoc """
  Imports all functionality for an ecto schema

  ### Usage

  ```
  defmodule Data.Schema.MySchema do
    use Data.Schema

    schema "my_schemas" do
      # Fields
    end
  end
  ```
  """
  defmacro __using__(_opts) do
    quote do
      use Ecto.Schema
      import H2nApi.Schema
      import Ecto.Changeset

      primary_key =
        if Application.get_env(:securex, :type) == :binary_id,
           do: {:id, :binary_id, autogenerate: true}, else: {:id, :id, autogenerate: true}

      foreign_key_type =
        if Application.get_env(:securex, :type) === :binary_id, do: Ecto.UUID, else: :id

      @primary_key primary_key
      @foreign_key_type foreign_key_type

      @timestamps_opts [type: :utc_datetime]
    end
  end

  defmacro timestamp() do
    quote do
      field :deleted_at, :utc_datetime
      timestamps()
    end
  end
end
