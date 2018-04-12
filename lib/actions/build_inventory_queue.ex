defmodule FileSync.Actions.BuildInventoryQueue do

  alias FileSync.Actions.Queue
  alias FileSync.Data.InventoryItem

  def push_to_queue({:ok, items}, queue) do
    items
    |> Enum.each(&add_to_queue(&1, queue))
  end

  def add_to_queue(item = %InventoryItem{}, queue) do
    queue |> Queue.push(item)
  end

  # don't do anything with Folders, at least not yet
  def add_to_queue(_item, _queue) do
  end
end
