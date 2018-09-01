defmodule FileSync.Boundaries.DropBox.SyncStrategies.Paginate do

  alias FileSync.Interactions.Source
  alias FileSync.Actions.Queue
  alias FileSync.Boundaries.DropBox.{
    Client,
    Response
  }
  
  def check(opts) do
    with_defaults = opts |> Enum.into(%{client: Client})

    list_folder(with_defaults)
    |> handle_response(with_defaults)
  end

  defp list_folder(%{client: client, source: %Source{opts: source_opts}}) do
    %{
      folder: source_opts[:folder],
      limit: source_opts[:limit] || 100
    }
    |> client.list_folder
  end

  defp handle_response({:ok, %Response{body: body}}, %{queue: queue}) do
    body[:entries]
    |> Enum.each(fn(item) -> queue |> Queue.push(item) end)

    {:ok, %{
      has_more: body[:has_more],
      cursor: body[:cursor]
    }}
  end

  defp handle_response({:error, message}, _defaults) do
    {:error, message}
  end
end
