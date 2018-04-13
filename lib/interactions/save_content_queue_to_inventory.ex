defmodule FileSync.Interactions.SaveContentQueueToInventory do
  alias FileSync.Actions.Queue

  def save_to(queue, inventory, opts) do
    item = queue |> Queue.pop

    item
    |> inventory.put(opts)
    |> handle_put_message(queue, item)
  end

  defp handle_put_message({:ok, _message}, _queue, _item) do
  end

  defp handle_put_message({:error, _messsage}, queue, item) do
    queue |> Queue.push(item)
  end
end
