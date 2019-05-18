defmodule FileSync.Boundaries.DropBox.FileContents do

  alias FileSync.Data.{
    FileData,
    InventoryItem,
    InventoryFolder
  }
  alias FileSync.Boundaries.DropBox.{
    Client,
    SourceMeta,
    Endpoints,
    ResponseParsers,
    Options
  }

  def get(item, opts, client \\ Client)
  def get(%InventoryItem{path: path}, opts = %Options{}, client) do

    endpoint = Endpoints.Download
    parser = ResponseParsers.Download

    opts
    |> Map.from_struct
    |> Map.merge(%{path: path})
    |> client.request(endpoint, parser)
    |> respond
  end

  def get(_item = %InventoryFolder{}, _opts, _client) do
    # folder traversal not yet implemented
  end

  defp respond({:ok, response}) do
    {:ok, build_file_data(response)}
  end

  defp respond(response) do
    response
  end

  defp build_file_data(response) do
    %FileData{
      content: response.body,
      name: response.headers["file_data"]["name"],
      size: response.headers["file_data"]["size"],
      source_meta: source_meta(response)
    }
  end

  defp source_meta(response) do
    %SourceMeta{
      content_hash: response.headers["file_data"]["content_hash"]
    }
  end
end
