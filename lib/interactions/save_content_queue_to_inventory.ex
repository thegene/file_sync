defmodule FileSync.Interactions.SaveContentQueueToInventory do
  alias FileSync.Actions.Queue

  def save_to(queue, inventory, opts) do
    queue
    |> Queue.pop
    |> inventory.put(opts)
  end
end
