defmodule SecureX.Helper do
  @moduledoc false

  @spec keys_to_atoms(any()) :: map()
  def keys_to_atoms(string_key_map) when is_map(string_key_map) do
    for {key, val} <- string_key_map, into: %{} do
      if is_struct(val) do
        if val.__struct__ in [DateTime, NaiveDateTime, Date, Time] do
          {String.to_atom(key), val}
        else
          {String.to_atom(key), keys_to_atoms(val)}
        end
      else
        {String.to_atom(key), keys_to_atoms(val)}
      end
    end
  end

  def keys_to_atoms(string_key_list) when is_list(string_key_list) do
    string_key_list
    |> Enum.map(&keys_to_atoms/1)
  end

  def keys_to_atoms(value), do: value

  @spec trimmed_downcase(String.t()) :: String.t()
  def trimmed_downcase(str), do: str |> String.trim |> downcase

  @spec downcase(String.t()) :: String.t()
  def downcase(str), do: str |> String.downcase() |> String.replace(" ", "_")

  @spec abort(any(), any(), any()) :: atom()
  def abort(_, _, _), do: :abort

  @spec default_resp(any(), Keyword.t()) :: tuple()
  def default_resp(result, opts \\ [])

  def default_resp([], mode: :reverse, msg: msg), do: ok(msg)

  def default_resp([], msg: err), do: err |> error()

  def default_resp([], _), do: error()

  def default_resp(result, mode: :reverse, msg: err) when is_list(result), do: err |> error()

  def default_resp(result, _) when is_list(result), do: ok(result)

  def default_resp({_, nil}, msg: err), do: err |> error()

  def default_resp({_, nil}, _), do: error()

  def default_resp({_, result}, _) when is_list(result), do: ok(result)

  def default_resp({:error, changeset}, _), do: changeset_error(changeset)

  def default_resp(result, _) when is_tuple(result), do: result

  def default_resp(result, mode: :reverse) when is_nil(result), do: ok(result)

  def default_resp(result, _) when is_nil(result), do: error(result)

  def default_resp(_, mode: :reverse, msg: err), do: err |> error()

  def default_resp(result, mode: :reverse), do: result |> error()

  def default_resp(result, _), do: result |> ok

  @spec changeset_error(struct()) :: tuple()
  def changeset_error(%Ecto.Changeset{errors: errors}) do
    {key, {msg, _}} = List.first(errors)
    {:error, "#{key} #{msg}"}
  end

  def changeset_error(err), do: err |> error

  @spec ok(any()) :: tuple()
  def ok(data) when is_tuple(data), do: data

  def ok(data), do: {:ok, data}

  @spec error(any()) :: tuple()
  def error(data \\ "Doesn't Exist!")

  def error(data) when is_tuple(data), do: data

  def error(nil), do: {:error, "Doesn't Exist!"}

  def error(err), do: {:error, err}
end
