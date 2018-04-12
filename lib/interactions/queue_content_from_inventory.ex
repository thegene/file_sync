defmodule FileSync.Interactions.QueueContentFromInventoryQueue do

  alias FileSync.Actions.{Queue,Validator}
  alias FileSync.Data.InventoryItem

  def process(inventory_queue, content_queue, source, opts \\ %{}) do
    item = inventory_queue |> Queue.pop

    item
    |> get_data(source, opts)
    |> validate(source.validators)
    |> enqueue(inventory_queue, content_queue, item, opts)
  end

  defp get_data(item = %InventoryItem{}, source, opts) do
    item |> source.contents.get(opts)
  end

  defp validate(message, validators) do
    message |> Validator.validate_with(validators)
  end

  defp enqueue({:ok, file_data}, _inventory_queue, content_queue, _original_item, opts) do
    content_queue |> Queue.push(file_data)

    opts |> info("successfully enqueued content for #{file_data.name}")
  end

  defp enqueue({:error, message}, inventory_queue, _content_queue, original_item, opts) do
    inventory_queue |> Queue.push(original_item)

    opts |> error("failed getting #{original_item.name}, will retry: #{message}")
  end

  defp error(opts, message) do
    logger = logger_from_opts(opts)
    logger.error(message)
  end

  defp info(opts, message) do
    logger = logger_from_opts(opts)
    logger.info(message)
  end

  defp logger_from_opts(opts) do
    opts |> Map.get(:logger, Logger)
  end
end
