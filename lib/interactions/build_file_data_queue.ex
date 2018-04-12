defmodule FileSync.Interactions.BuildFileDataQueue do

  require IEx
  alias FileSync.Interactions.Queue

  def process_to(inventory_queue, file_data_queue, contents, validators) do
    item = inventory_queue |> Queue.pop

    item
    |> contents.get
    |> validate(validators)
    |> handle_item(file_data_queue, inventory_queue, item)
  end

  defp validate(response = {:ok, _data}, []) do
    response
  end

  defp validate({:ok, data}, validators) do
    [validator | rest] = validators

    data
    |> validator.valid?
    |> validate(rest)
  end

  defp validate(response, _validators) do
    response
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
