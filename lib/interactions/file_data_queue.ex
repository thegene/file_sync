defmodule FileSync.Interactions.FileDataQueue do

  alias FileSync.Interactions.Queue

  def process_to(inventory_queue, file_data_queue, inventory) do
    item = inventory_queue |> Queue.pop

    item
    |> inventory.get
    |> handle_item(file_data_queue, inventory_queue, item)
  end

  defp handle_item({:ok, data}, data_queue, _inventory_queue, _item) do
    data_queue |> Queue.push(data)
    {:ok, "Successfully queued #{data.name}"}
  end

  defp handle_item(response, _data_queue, inventory_queue, item) do
    inventory_queue |> Queue.push(item)
    response
  end
end
