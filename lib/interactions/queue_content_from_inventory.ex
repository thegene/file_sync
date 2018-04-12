defmodule FileSync.Interactions.QueueContentFromInventoryQueue do

  alias FileSync.Actions.Queue
  alias FileSync.Data.InventoryItem

  def process(inventory_queue, content_queue, source, opts \\ %{}) do
    inventory_queue
    |> Queue.pop
    |> get_data(source, opts)
    |> enqueue(inventory_queue, content_queue, opts)
  end

  defp get_data(item = %InventoryItem{}, source, opts) do
    item |> source.contents.get(opts)
  end

  defp enqueue({:ok, file_data}, _inventory_queue, content_queue, opts) do
    content_queue |> Queue.push(file_data)

    opts |> info("successfully enqueued content for #{file_data.name}")
  end

  defp info(opts, message) do
    logger = logger_from_opts(opts)
    logger.info(message)
  end

  defp logger_from_opts(opts) do
    opts |> Map.get(:logger, Logger)
  end
end
