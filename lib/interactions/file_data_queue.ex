defmodule FileSync.Interactions.FileDataQueue do

  alias FileSync.Interactions.Queue
  alias FileSync.Data.FileData

  def process_to(inventory_queue, file_data_queue, inventory) do
    inventory_queue
    |> Queue.pop
    |> inventory.get
    |> process_inventory_item(file_data_queue)
  end

  defp process_inventory_item(data = %FileData{}, file_data_queue) do
    file_data_queue
    |> Queue.push(data)
  end

  defp process_inventory_item(_data, _file_data_queue) do
  end
end
