defmodule FileSync.Interactions.SyncServer do
  require IEx

  alias FileSync.Interactions.BuildInventoryQueue

  def sync(opts) do
    source = opts |> Keyword.get(:source)
    inventory_queue = opts |> Keyword.get(:queue)

    source
    |> get_inventory_items
    |> build_inventory_queue(inventory_queue)
  end

  defp get_inventory_items(source) do
    source.inventory.get(source.opts)
  end

  defp build_inventory_queue({:ok, items}, queue) do
    BuildInventoryQueue.push_to_queue(items, queue)
  end

  defp build_inventory_queue(_res, _queue) do
  end
end
