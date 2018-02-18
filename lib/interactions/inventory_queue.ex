defmodule FileSync.Interactions.InventoryQueue do

  alias FileSync.Interactions.Queue
  alias FileSync.Data.InventoryItem

  def push_to_queue(inventory_response, {:ok, queue}) do
    {:ok, list} = inventory_response

    list
    |> Enum.each(&add_to_queue(&1, queue))
  end

  def add_to_queue(item = %InventoryItem{}, queue) do
    queue |> Queue.push(item)
  end

  def add_to_queue(_item, _queue) do
  end
end
