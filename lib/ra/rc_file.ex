defmodule Ra.RcFile do

  def exist?(module), do: module |> filename |> File.exists?

  def touch(dict, module) do
    dict
    |> Map.keys
    |> Enum.map(&("#{to_string(&1)}: #{Map.get(dict, &1)}"))
    |> Enum.join("\n")
    |> _write(module)
  end

  defp _write(content, module), do: module |> filename |> File.write(content)

  def load(module), do: _load(exist?(module), module)

  defp _load(false, _), do: %{}
  defp _load(_, module) do
    module
    |> filename
    |> File.read!
    |> String.split("\n")
    |> parse
  end

  defp parse(lines), do: _parse(lines, %{})

  defp _parse([], dict), do: dict
  defp _parse([pair|tail], dict) do
    [key, value] = pair |> String.split(": ")
    _parse(tail, Map.put(dict, String.to_atom(key), parse_value(value)))
  end

  defp parse_value("false"), do: false
  defp parse_value("true"), do: true
  defp parse_value(value), do: try_parse(value)

  defp try_parse(value), do: try_parse_as_integer(value) || try_parse_as_float(value) || value

  defp try_parse_as_integer(candidate) do
    case Integer.parse(candidate) do
      {value, ""} -> value
      _           -> nil
    end
  end

  defp try_parse_as_float(candidate) do
    case Float.parse(candidate) do
      {value, ""} -> value
      _           -> nil
    end
  end

  def filename(module) do
    module
    |> to_string
    |> String.downcase
    |> String.split(".")
    |> _filename
    |> _path
  end

  defp _filename(["elixir", "mix", "tasks"|filename]), do: ".#{filename |> Enum.join("_")}.rc"
  defp _filename(["elixir" | list]), do: ".#{list |> Enum.join("_")}.rc"

  defp _path(filename), do: Path.join("~", filename) |> Path.expand

end
