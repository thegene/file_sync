defmodule FileSync.Boundaries.DropBox.Inventory do

  alias FileSync.Boundaries.DropBox.Client

  def get(opts) do
    opts
    |> find_client(opts).list_folder
    |> parse
  end

  defp find_client(opts) do
    Map.get(opts, :client, Client)
  end

  defp parse({:ok, response}) do
    response
    |> Map.get(:body)
    |> Map.get(:entries)
    |> cast_entries
    |> build_successful_response
  end

  defp parse({:error, reason}) do
    {:error, reason}
  end

  defp build_successful_response(entries) do
    {:ok, entries}
  end

  defp cast_entries(entries) do
    entries
    |> Enum.map(fn(entry) -> cast_single_entry(entry) end)
  end

  defp cast_single_entry(%{
                           ".tag" => "file",
                           "name" => name,
                           "size" => size,
                           "path_lower" => path
                         }) do
    %FileSync.Data.InventoryItem {
      name: name,
      size: size,
      path: path
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
