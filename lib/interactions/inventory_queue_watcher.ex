defmodule FileSync.Interactions.InventoryQueueWatcher do
  #use GenServer

  alias FileSync.Interactions.QueueContentFromInventoryQueue

  def init(inventory_queue, content_queue, source) do

  end

  def check_queue(inventory_queue, content_queue, source, module \\ QueueContentFromInventoryQueue) do
    module.process(
      inventory_queue,
      content_queue,
      source
    )
    |> handle_response(source.logger)
  end

  defp handle_response({:ok, _message}, _logger) do
  end

  defp handle_response({:error, message}, logger) do
    logger.warn(logger)
  end
end
