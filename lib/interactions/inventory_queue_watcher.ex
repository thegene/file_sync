defmodule FileSync.Interactions.InventoryQueueWatcher do
  use GenServer

  alias FileSync.Interactions.QueueContentFromInventoryQueue
  alias FileSync.Data.FileData

  def start_link(inventory_queue, content_queue, source) do
    state = build_state(inventory_queue, content_queue, source)
    GenServer.start_link(__MODULE__, state)
  end

  def init(state) do
    schedule()
    {:ok, state}
  end

  defp build_state(inventory_queue, content_queue, source) do
    %{
      inventory_queue: inventory_queue,
      content_queue: content_queue,
      source: source
    }
  end

  defp schedule, do: Process.send_after(self(), :watch, delay())

  defp delay, do: 1000 * 10

  def handle_info(:watch, state) do
    check_queue(
      state.inventory_queue,
      state.content_queue,
      state.source
    )
    schedule()
    {:noreply, state}
  end

  def check_queue(inventory_queue, content_queue, source, module \\ QueueContentFromInventoryQueue) do
    module.process(
      inventory_queue,
      content_queue,
      source
    )
    |> handle_response(source.logger)
  end

  defp handle_response({:ok, file_data = %FileData{}}, logger) do
    logger.warn(file_data.name)
  end

  defp handle_response({:ok, message}, logger) do
    logger.warn(message)
  end

  defp handle_response({:error, message}, logger) do
    logger.warn(message)
  end
end