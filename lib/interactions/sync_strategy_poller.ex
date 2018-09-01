defmodule FileSync.Interactions.SyncStrategyPoller do
  alias FileSync.Interactions.Source
  
  def poll(source = %Source{}, strategy, queue) do
    strategy.check(
      %{},
      source,
      queue
    )
  end
end
