defmodule FileSync.Interactions.InventoryQueue do

  alias FileSync.Interactions.Queue
  alias FileSync.Data.InventoryItem

  def push_to_queue({:ok, items}, queue) do
    items
    |> Map.fetch!(:items)
    |> Enum.each(&add_to_queue(&1, queue))
  end

  def add_to_queue(item = %InventoryItem{}, queue) do
    queue |> Queue.push(item)
  end

  def add_to_queue(_item, _queue) do
  end
end
