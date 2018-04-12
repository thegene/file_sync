defmodule FileSync.Interactions.QueueContentFromInventoryQueue do

  alias FileSync.Actions.Queue

  def process(inventory_queue, content_queue, source, opts \\ %{}) do
    item = inventory_queue |> Queue.pop
    content_queue |> Queue.push(item)
  end
end
