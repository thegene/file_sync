defmodule FileSync.Interactions.SyncStrategyWatcher do
  use GenServer

  alias FileSync.Interactions.Source
  alias FileSync.Actions.Queue
  
  def start_link(inventory_queue: queue_name, source: source) do
    state = %{
      queue: Queue.find_queue(queue_name),
      source: source,
      last_response: %{}
    }
    GenServer.start_link(__MODULE__, state)
  end

  @impl true
  def init(state) do
    schedule()
    {:ok, state}
  end

  @impl true
  def handle_info(:poll, state) do
    last_response = poll(
      state.last_response,
      state.source,
      state.queue
    )

    {:noreply, state |> Map.merge(%{last_response: last_response})}
  end

  defp schedule, do: Process.send_after(self(), :poll, delay())

  defp delay, do: 1000 * 60 * 5

  def poll({:ok, last_response}, source = %Source{}, queue) do
    heartbeat_log(source)
    source.strategy.check(
      last_response,
      source,
      queue
    ) |> handle_response(source)
  end

  def poll(_last_response, source = %Source{}, queue) do
    heartbeat_log(source)
    source.strategy.check(
      %{},
      source,
      queue
    ) |> handle_response(source)
  end

  defp heartbeat_log(%Source{logger: logger}) do
    logger.info("Watching for new files to sync")
  end

  defp handle_response(last_response = {:ok, _anything}, _source) do
    last_response
  end

  defp handle_response(last_response = {:error, message}, %Source{logger: logger}) do
    logger.warn(message)
    last_response
  end
end
