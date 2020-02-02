defmodule FileSync.Interactions.QueueContentFromInventoryQueue do

  alias FileSync.Actions.{Queue,Validator}
  alias FileSync.Data.InventoryItem

  def process(inventory_queue, content_queue, source) do
    item = inventory_queue |> Queue.pop

    item
    |> get_data(source)
    |> validate(source)
    |> enqueue(inventory_queue, content_queue, item)
  end

  defp get_data(item = %InventoryItem{}, source) do
    item |> source.contents.get(source.opts)
  end

  defp get_data(nil, _source) do
    {:ok, nil}
  end

  defp validate(message, source) do
    message |> Validator.validate_with(source)
  end

  defp enqueue({:ok, nil}, _inventory_queue, _content_queue, _original_item) do
    {:ok, "Inventory queue is empty"}
  end

  defp enqueue({:ok, file_data}, _inventory_queue, content_queue, _original_item) do
    content_queue |> Queue.push(file_data)

    {:ok, "Successfully enqueued content for #{file_data.name}"}
  end

  defp enqueue({:error, message}, inventory_queue, _content_queue, original_item) do
    inventory_queue |> Queue.push(original_item)

    {:error, "QueueContentFromInventoryQueue: file contents failed. "
      <> "#{original_item.name} will retry: #{message}"}
  end
end
