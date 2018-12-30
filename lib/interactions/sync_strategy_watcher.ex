defmodule FileSync.Interactions.SyncStrategyWatcher do
  alias FileSync.Interactions.Source
  
  def poll({:ok, last_response}, source = %Source{}, strategy, queue) do
    strategy.check(
      last_response,
      source,
      queue
    ) |> handle_response(source)
  end

  def poll(_last_response, source = %Source{}, strategy, queue) do
    strategy.check(
      %{},
      source,
      queue
    ) |> handle_response(source)
  end

  defp handle_response(last_response = {:ok, _anything}, _source) do
    last_response
  end

  defp handle_response(last_response = {:error, message}, %Source{logger: logger}) do
    logger.warn(message)
    last_response
  end
end
