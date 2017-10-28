defmodule FileSync.Boundaries.DropBox.ResponseParser do

  def parse({:ok, %HTTPoison.Response{body: body}}) do
    body
    |> Poison.decode!
    |> Map.get("entries")
    |> cast_entries
    |> build_return_struct
  end

  defp build_return_struct(entries) do
    {:ok, %{
      items: entries
    }}
  end

  defp cast_entries(entries) do
    entries
    |> Enum.map(fn(entry) -> cast_single_entry(entry) end)
  end

  defp cast_single_entry(%{
                           ".tag" => "file",
                           "name" => name,
                           "size" => size
                         }) do
    %FileSync.Data.InventoryItem {
      name: name,
      size: size
    }
  end

  defp cast_single_entry(%{
                           ".tag" => "folder",
                           "name" => name
                         }) do
    %FileSync.Data.InventoryFolder {
      name: name
    }
  end

end
