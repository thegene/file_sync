defmodule FileSync.Interactions.ContentQueueWatcher do

  alias FileSync.Interactions.{
    SaveContentQueueToInventory,
    Source
  }

  def check_queue(content_queue, target = %Source{}, module \\ SaveContentQueueToInventory) do
    content_queue
    |> module.save_to(target)
    |> handle_response(target.logger)
  end

  def handle_response({_success, message}, logger) do
    logger.warn(message)
  end
end
