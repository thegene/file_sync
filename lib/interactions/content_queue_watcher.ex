defmodule FileSync.Interactions.ContentQueueWatcher do
  use GenServer

  alias FileSync.Actions.Queue
  alias FileSync.Interactions.{
    SaveContentQueueToInventory,
    Source
  }

  def start_link(content_queue: content_queue, target: target) do
    state = %{
      content_queue: Queue.find_queue(content_queue),
      target: target
    }
    GenServer.start_link(__MODULE__, state)
  end

  @impl true
  def init(state) do
    schedule()
    {:ok, state}
  end

  @impl true
  def handle_info(:watch, state) do
    check_queue(
      state.content_queue,
      state.target
    )
    schedule()
    {:noreply, state}
  end

  def check_queue(
    content_queue,
    target = %Source{},
    module \\ SaveContentQueueToInventory
  ) do
    content_queue
    |> module.save_to(target)
    |> handle_response(target.logger)
  end

  defp schedule, do: Process.send_after(self(), :watch, delay())

  defp delay, do: 1000 * 10

  def handle_response({:error, message}, logger) do
    logger.warn(message)
  end

  def handle_response({:ok, message}, logger) do
    logger.info(message)
  end
end
