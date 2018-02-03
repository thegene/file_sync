defmodule FileSync.Interactions.SyncSingleBatch do
  alias FileSync.Data.{InventoryItem,InventoryFolder}

  def sync(from: from, to: to) do
    inventory = from.module.inventory

    from.opts
    |> inventory.get
    |> sync_inventory(from, to)
  end

  defp is_item?(%InventoryItem{}), do: true
  defp is_item?(%InventoryFolder{}), do: false

  defp items_only(inventory) do
    Enum.filter(inventory, fn(item) -> is_item?(item) end)
  end

  defp sync_inventory({:error, message}, _from, _to) do
    raise "Failed to get inventory: #{message}"
  end

  defp sync_inventory({:ok, response}, from, to) do
    response
    |> Map.get(:items)
    |> items_only
    |> get_contents(from)
    |> sync_items(to)
  end

  defp get_contents(items, from) do
    Enum.map(items, fn(item) -> from.module.file_contents.get(item) end)
  end

  defp sync_items(items, to) do
    Enum.each(items, fn(item) -> spawn fn -> sync_item(item, to) end end)
  end

  defp sync_item({:ok, data}, to) do
    destination = to.module.file_contents()

    data |> destination.put(to.opts)
  end

  defp sync_item({:error, message}, _to) do
    raise "Failed to get contents: #{message}"
  end
end
