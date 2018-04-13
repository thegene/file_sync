defmodule FileSync.Interactions.SaveContentQueueToInventory do

  alias FileSync.Actions.{Queue,Validator}
  alias FileSync.Interactions.Source

  def save_to(queue, source = %Source{}, dependencies) do
    item = queue |> Queue.pop

    item
    |> source.contents.put(source.opts)
    |> validate(source)
    |> handle_message(queue, item, dependencies)
  end

  defp validate(message = {:ok, _data}, source) do
    message |> Validator.validate_with(source)
  end

  defp validate(res, _validators), do: res

  defp handle_message({:ok, _message}, _queue, item, dependencies) do
    dependencies |> info("Successfully saved #{item.name}")
  end

  defp handle_message({:error, message}, queue, item, dependencies) do
    queue |> Queue.push(item)
    dependencies |> error("Failed to save #{item.name}, requeueing: #{message}")
  end

  def error(dependencies, message) do
    logger = dependencies |> Map.get(:logger, Logger)
    logger.error(message)
  end

  def info(dependencies, message) do
    logger = dependencies |> Map.get(:logger, Logger)
    logger.info(message)
  end
end
