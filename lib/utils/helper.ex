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
  def trimmed_downcase(str), do: str |> String.trim() |> downcase

  @spec downcase(String.t()) :: String.t()
  def downcase(str), do: str |> String.downcase() |> String.replace(" ", "_")

  @spec abort(any(), any(), any()) :: atom()
  def abort(_, _, _), do: :abort

  @spec default_resp(any(), Keyword.t()) :: tuple()
  def default_resp(result, opts \\ [])

  @doc """
   sends response for the Ecto.all, and list responses.
    In mode: :reverse we are doing to inverse of response like '[]'  will indicate success and '[struct]' will indicate error.

  ##Examples
    `some_query |> repo.all`
       this will return `[]` or `[structs]`  so we can handle that response as
      'if '[]' or '[structs]', do:some_query |> repo.all |> default_resp()'
      'if '[]', do: some_query |> repo.all |> default_resp(msg: error_msg)'
      'if '[]', do: some_query |> repo.all |> default_resp(mode: :reverse,msg: success_msg)'
      'if '[structs]', do: some_query |> repo.all |> default_resp(mode: :reverse,msg: error_msg)'

    merges transactions of a sage.

  ##Examples

    `defp create_employee_sage(input) do
      new()
      |> run(:employee, &create_employee/2, &abort/3)
      |> run(:salary, &create_salary/2, &abort/3)
      |> transaction(MyApp.Repo, input)
    end`

      and we like to merge two transactions like employee data and its salary as
     `{:ok, _, result} |> default_resp(in: salary, [employee: employee])`

     gets data from transactions of a sage.

  ##Examples

    'defp create_employee_sage(input) do
      new()
      |> run(:employee, &create_employee/2, &abort/3)
      |> run(:salary, &create_salary/2, &abort/3)
      |> transaction(MyApp.Repo, input)
    end'

      and we can to get employee as
     `{:ok, _, result} |> default_resp(key: employee)`

      sends response for the Ecto.insert_all,Ecto.insert_all and Ecto.insert_all.
    In mode: :reverse we are doing to inverse of response like '{integer,nil}'  will indicate success and '{integer,[structs]}' will indicate error.

  ##Examples

    `some_query |> repo.insert_all`
       this will return `{integer,nil}` or `{integer,[structs]}`  so we can handle that response as
      'if '{integer,nil} or {integer,[structs]}', do:some_query |> repo.insert_all |> default_resp()'
      'if '{integer,nil}', do: some_query |> repo.insert_all |> default_resp(msg: error_msg)'
      'if '{integer,nil}', do: some_query |> repo.insert_all |> default_resp(mode: :reverse,msg: success_msg)'
      'if '{integer,[structs]}', do: some_query |> repo.insert_all |> default_resp(mode: :reverse,msg: error_msg)'

      sends response for the changeset errors in functions  Ecto.insert , Ecto.update,Ecto.delete.

  ##Examples

    `some_query |> repo.insert`
       this will return `{:ok,struct}` or `{:error,changeset}`  so we can handle that response as
      'if '{:error,changeset}', do: some_query |> repo.insert |> default_resp()'

      sends response for the Ecto.get, Ecto.get_by,Ecto.one and functions that will return nil or struct.
    Also works for Ecto.insert ,Ecto.update and Ecto.delete.
    In mode: :reverse we are doing to inverse of response like 'nil'  will indicate success and 'struct' will indicate error.

  ##Examples

    `some_query |> repo.get`
       this will return `nil` or `struct`  so we can handle that response as

      'if 'nil or struct', do:some_query |> repo.get |> default_resp()'
      'if 'nil or struct', do: some_query |> repo.insert_all |> default_resp(mode: :reverse)'

    `some_query |> repo.create`
       this will return `{:ok,struct}` or ;{:error,changeset}'  so we can handle that response as

      'some_query |> repo.insert |> default_resp()'
      'some_query |> repo.update |> default_resp()'
      'some_query |> repo.delete |> default_resp()'

     default_resp returns tuple as

       'result |> default_resp()' Returns {:ok,result}
       'default_resp(mode: :reverse,msg: error)' Returns {:error,error}
       'params |> default_resp()' Returns {:ok, params}

    send custom data instead of error message
    in case of nil i want to return something custom
      repo.get() |> default_resp(mode: custom, any: :any_data)
  """

  def default_resp([], mode: :reverse, msg: msg), do: ok(msg)

  def default_resp([], msg: err), do: err |> error()

  def default_resp([], _), do: error()

  def default_resp(result, mode: :reverse, msg: err) when is_list(result), do: err |> error()

  def default_resp(result, _) when is_list(result), do: ok(result)

  def default_resp({:ok, _, result}, in: in_, keys: keys) when is_map(result) do
    in_ = result[in_]

    case is_map(in_) do
      true ->
        Enum.reduce(keys, in_, fn {key, value}, acc ->
          Map.put(acc, value, result[key])
        end)
        |> ok()

      false ->
        result[in_]
    end
  end

  def default_resp({:ok, _, result}, key: key) when is_map(result),
    do: result |> Map.get(key) |> ok()

  def default_resp({_, nil}, mode: :reverse, msg: msg), do: ok(msg)

  def default_resp({_, nil}, msg: err), do: err |> error()

  def default_resp({_, nil}, _), do: error()

  def default_resp({_, result}, msg: msg) when is_list(result), do: ok(msg)

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

  @doc """
    sends ok tuple.

  ##Examples
      'result |> ok()' Returns {:ok, result}
  """
  @spec ok(any()) :: tuple()
  def ok(data) when is_tuple(data), do: data

  def ok(data), do: {:ok, data}

  @doc """
    sends error tuple.

  ##Examples
      'error |> error()' Returns {:error,error}
  """
  @spec error(any()) :: tuple()
  def error(data \\ "Doesn't Exist!")

  def error(data) when is_tuple(data), do: data

  def error(nil), do: {:error, "Doesn't Exist!"}

  def error(err), do: {:error, err}
end
