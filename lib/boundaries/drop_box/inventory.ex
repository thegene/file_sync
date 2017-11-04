defmodule FileSync.Boundaries.DropBox.Inventory do

  alias FileSync.Boundaries.DropBox.ResponseParser

  def get(folder: folder, client: client) do
    folder
    |> client.list_folder
    |> parse
  end

  def parse({:ok, response}) do
    response
    |> Map.get("entries")
    |> cast_entries
    |> build_successful_response
  end

  defp build_successful_response(entries) do
    {:ok, %{items: entries}}
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
