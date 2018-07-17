defmodule FileSync.Interactions.SyncServer do
  require IEx

  alias FileSync.Actions.Queue
  alias FileSync.Interactions.{
    BuildInventoryQueue,
    QueueContentFromInventoryQueue,
    SaveContentQueueToInventory
  }

  def sync(opts) do
    source = opts |> Keyword.get(:source)
    target = opts |> Keyword.get(:target)

    inventory = find_queue(source.queue_name)
    contents = find_queue(target.queue_name)

    source
    |> get_inventory_items
    |> populate_inventory_queue(inventory)
    
    inventory
    |> populate_content_queue(contents, source)

    contents
    |> save_to_target(target)
  end

  defp save_to_target(content_queue, target) do
    content_queue
    |> SaveContentQueueToInventory.save_to(target)
  end

  defp populate_content_queue(inventory, contents, source) do
    QueueContentFromInventoryQueue.process(inventory, contents, source)

    if !Queue.empty?(inventory) do
      inventory |> populate_content_queue(contents, source)
    end
  end

  defp find_queue(name) do
    Queue.find_queue(name) || new_queue(name)
  end

  defp new_queue(name) do
   {:ok, queue} = Queue.start_link(agent: [name: name])
   queue
  end

  defp get_inventory_items(source) do
    source.inventory.get(source.opts)
  end

  defp populate_inventory_queue({:ok, items}, queue) do
    BuildInventoryQueue.push_to_queue(items, queue)
  end

  defp populate_inventory_queue(_res, _queue) do
  end
end
