defmodule FileSync.Interactions.SyncStrategyWatcher do
  alias FileSync.Interactions.Source
  
  def poll({:ok, last_response}, source = %Source{}, strategy, queue) do
    strategy.check(
      last_response,
      source,
      queue
    )
  end

  def poll(_last_response, source = %Source{}, strategy, queue) do
    strategy.check(
      %{},
      source,
      queue
    )
  end
end
