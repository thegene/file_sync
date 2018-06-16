defmodule FileSync.Interactions.SyncServer do
  require IEx

  alias FileSync.Actions.Queue
  alias FileSync.Interactions.BuildInventoryQueue

  def sync(opts) do
    source = opts |> Keyword.get(:source)

    content_queue = opts |> Keyword.get(:queue)

    source
    |> get_inventory_items
    |> build_inventory_queue(inventory_queue)
    
    inventory_queue |> populate_content_queue(content_queue)
  end

  #  defp content_queue do
  #    Queue.find_queue(:content) || new_content_queue()
  #  end
  #
  #  defp new_content_queue do
  #   {:ok, queue} = Queue.start_link(agent: [name: :content])
  #   queue
  #  end
  #
  defp inventory_queue do
    Queue.find_queue(:inventory) || new_inventory_queue()
  end

  defp new_inventory_queue do
   {:ok, queue} = Queue.start_link(agent: [name: :inventory])
   queue
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
