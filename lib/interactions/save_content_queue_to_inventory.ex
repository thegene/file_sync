defmodule FileSync.Interactions.SaveContentQueueToInventory do
  alias FileSync.Actions.Queue

  def save_to(queue, inventory, opts, dependencies) do
    item = queue |> Queue.pop

    item
    |> inventory.put(opts)
    |> handle_put_message(queue, item, dependencies)
  end

  defp handle_put_message({:ok, _message}, _queue, item, dependencies) do
    dependencies |> info("Successfully saved #{item.name}")
  end

  defp handle_put_message({:error, message}, queue, item, dependencies) do
    queue |> Queue.push(item)
    dependencies |> error("Failed to save #{item.name}, requeueing: #{message}")
  end

  def error(dependencies, message) do
    logger = dependencies |> Map.get(:logger, Logger)
    logger.error(message)
  end

  def info(dependencies, message) do
    logger = dependencies |> Map.get(:logger, Logger)
    logger.info(message)
  end
end
