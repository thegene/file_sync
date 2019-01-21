defmodule FileSync.Boundaries.DropBox.SyncStrategies.Paginate do
  defstruct [
    :folder, # The dropbox folder to paginate over
    :limit, # The number of items to request per page
  ]

  alias FileSync.Interactions.Source
  alias FileSync.Actions.Queue
  alias FileSync.Boundaries.DropBox.{
    Client,
    Response,
    Endpoints,
    ResponseParsers
  }
  
  def check(last_response, source, queue, deps)

  def check(%{cursor: cursor}, source = %Source{}, queue, deps) do
    client = deps[:client] || Client

    request_with_cursor(source, cursor, client)
    |> handle_response(queue)
  end

  def check(_last_response, source = %Source{}, queue, deps) do
    client = deps[:client] || Client

    request(client: client, source: source)
    |> handle_response(queue)
  end

  defp request_with_cursor(%Source{opts: opts}, cursor, client) do
    %{
      cursor: cursor,
      token: opts.token
    }
    |> client.request(
                      Endpoints.ListFolderContinue,
                      ResponseParsers.ListFolder
                     )
  end

  defp request(client: client, source: %Source{opts: opts}) do
    settings = opts.strategy_opts
    %{
      folder: settings.folder,
      limit: settings.limit || 100,
      token: opts.token
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
