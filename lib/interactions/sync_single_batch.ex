defmodule FileSync.Interactions.SyncSingleBatch do
  alias FileSync.Data.{InventoryItem,InventoryFolder}

  def sync(opts = %{from: from, from_opts: from_opts}) do
    inventory = from.inventory()

    from_opts
    |> inventory.get
    |> sync_inventory(opts)
  end

  defp is_item?(%InventoryItem{}), do: true
  defp is_item?(%InventoryFolder{}), do: false

  defp items_only(inventory) do
    Enum.filter(inventory, fn(item) -> is_item?(item) end)
  end

  defp sync_inventory({:error, message}, _opts) do
    raise "Failed to get inventory: #{message}"
  end

  defp sync_inventory({:ok, response}, opts) do
    response
    |> Map.get(:items)
    |> items_only
    |> get_contents(opts)
    |> sync_items(opts)
  end

  defp get_contents(items, %{from: from}) do
    Enum.map(items, fn(item) -> from.file_contents.get(item) end)
  end

  defp sync_items(items, opts) do
    Enum.each(items, fn(item) -> spawn fn -> sync_item(item, opts) end end)
  end

  defp sync_item({:ok, data}, %{to: to, to_opts: to_opts}) do
    destination = to.file_contents()

    data |> destination.put(to_opts)
  end

  defp sync_item({:error, message}, _opts) do
    raise "Failed to get contents: #{message}"
  end
end
