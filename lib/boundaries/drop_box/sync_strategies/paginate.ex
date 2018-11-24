defmodule FileSync.Boundaries.DropBox.SyncStrategies.Paginate do

  alias FileSync.Interactions.Source
  alias FileSync.Actions.Queue
  alias FileSync.Boundaries.DropBox.{
    Client,
    Response,
    Endpoints,
    ResponseParsers
  }
  
  def check(last_response, source, queue, client \\ Client)

  def check(%{cursor: cursor}, %Source{opts: %{token: token}}, queue, client) do
    %{cursor: cursor}
    |> Map.merge(%{token: token})
    |> client.request(Endpoints.ListFolderContinue, ResponseParsers.ListFolder)
    |> handle_response(queue)
  end

  def check(_last_response, source = %Source{}, queue, client) do
    list_folder(client: client, source: source)
    |> handle_response(queue)
  end

  defp list_folder(client: client, source: %Source{opts: source_opts}) do
    %{
      folder: source_opts[:folder],
      limit: source_opts[:limit] || 100,
      token: source_opts[:token]
    }
    |> client.request(Endpoints.ListFolder, ResponseParsers.ListFolder)
  end

  defp handle_response({:ok, %Response{body: body}}, queue) do
    body[:entries]
    |> Enum.each(fn(item) -> queue |> Queue.push(item) end)

    {:ok, %{
      has_more: body[:has_more],
      cursor: body[:cursor]
    }}
  end

  defp handle_response({:error, message}, _queue) do
    {:error, message}
  end
end
