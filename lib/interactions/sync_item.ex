defmodule FileSync.Interactions.SyncItem do
  alias FileSync.Interactions.Source

  def sync({:ok, data}, %Source{module: target_module, opts: target_opts}) do
    target_module
      .file_contents
      .put(data, target_opts)
    |> handle_response_message(data.name)
  end

  def sync(response, _source) do
    handle_response_message(response, "Item")
  end

  defp handle_response_message({:ok, _message}, file_name) do
    {:ok, "#{file_name} sync successful"}
  end

  defp handle_response_message({:error, message}, additional_message) do
    {:error, "#{additional_message} sync failed: #{message}"}
  end
end
