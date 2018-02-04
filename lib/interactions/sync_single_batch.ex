defmodule FileSync.Interactions.SyncSingleBatch do
  alias FileSync.Data.{InventoryItem,InventoryFolder}
  require IEx

  def sync(from: from, to: to, opts: opts) do
    inventory = from.module.inventory

    from.opts
    |> inventory.get
    |> sync_inventory(from, to, opts)
  end

  defp is_item?(%InventoryItem{}), do: true
  defp is_item?(%InventoryFolder{}), do: false

  defp items_only(inventory) do
    Stream.filter(inventory, fn(item) -> is_item?(item) end)
  end

  defp sync_inventory({:error, message}, _from, _to, opts) do
    opts.logger.error("Failed to get inventory: #{message}")
  end

  defp sync_inventory({:ok, response}, from, to, opts) do
    response
    |> Map.get(:items)
    |> items_only
    |> get_contents(from)
    |> sync_items(to, opts)
  end

  defp get_contents(items, from) do
    Stream.map(items, fn(item) -> from.module.file_contents.get(item) end)
  end

  defp sync_items(items, to, opts) do
    Enum.each(items, fn(item) -> spawn fn -> sync_item(item, to, opts) end end)
  end

  defp sync_item({:ok, data}, to, opts) do
    destination = to.module.file_contents

    data
    |> destination.put(to.opts)
    |> handle_put_response(opts)
  end

  defp sync_item({:error, message}, _to, _opts) do
    {:error, "Failed to get contents: #{message}"}
  end

  defp handle_put_response(response, opts) do
    case response do
      {:ok, message} -> opts.logger.info(message)
      {:error, message} -> opts.logger.error(message)
    end
  end
end
