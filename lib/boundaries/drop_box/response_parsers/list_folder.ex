defmodule FileSync.Boundaries.DropBox.ResponseParsers.ListFolder do

  alias FileSync.Boundaries.DropBox.Response
  alias FileSync.Data.InventoryItem

  def parse(%{status_code: 200, headers: headers, body: body}) do
    %Response{
      status_code: 200,
      headers: Enum.into(headers, %{}),
      body: body |> Poison.decode! |> build_response_body
    }
  end

  defp build_response_body(body) do
    %{
      entries: inventory_items_from_entries(body["entries"]),
      cursor: body["cursor"],
      has_more: body["has_more"]
    }
  end

  defp cast_to_inventory_item(entry) do
    %InventoryItem{
      name: entry["name"],
      path: entry["path_display"],
      size: entry["size"]
    }
  end

  defp inventory_items_from_entries(entries) do
    entries |> Enum.map(fn(entry) -> entry |> cast_to_inventory_item end)
  end
end
