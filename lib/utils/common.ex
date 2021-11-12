defmodule SecureX.Common do
  @moduledoc false

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
end