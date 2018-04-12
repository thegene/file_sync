defmodule FileSync.Boundaries.DropBox.FileContents do

  require IEx

  alias FileSync.Data.{FileData,InventoryItem,InventoryFolder}
  alias FileSync.Boundaries.DropBox.{Client,SourceMeta}

  def get(item, opts \\ %{})
  def get(%InventoryItem{path: path}, opts) do

    client = Map.get(opts, :client, Client)

    client.download(%{path: path})
    |> respond
  end

  def get(_item = %InventoryFolder{}, _opts) do
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
