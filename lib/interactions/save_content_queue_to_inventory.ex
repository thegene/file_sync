defmodule FileSync.Interactions.SaveContentQueueToInventory do

  alias FileSync.Actions.{Queue,Validator}
  alias FileSync.Interactions.Source

  def save_to(queue, source = %Source{}) do
    item = queue |> Queue.pop

    item
    |> source.contents.put(source.opts)
    |> validate(source)
    |> handle_message(queue, item)
  end

  defp validate(message = {:ok, _data}, source) do
    message |> Validator.validate_with(source)
  end

  defp validate(res, _validators), do: res

  defp handle_message({:error, message}, queue, item) do
    queue |> Queue.push(item)
    {:error, "Failed to save #{item.name}, requeueing: #{message}"}
  end

  defp handle_message({:ok, _message}, _queue, item) do
    {:ok, "Successfully saved #{item.name}"}
  end
end
