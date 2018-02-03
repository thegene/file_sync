defmodule FileSync.Boundaries.DropBox.FileContents do

  alias FileSync.Data.{FileData,InventoryItem,InventoryFolder}
  alias FileSync.Boundaries.DropBox.Client

  def get(item, opts \\ %{})
  def get(%InventoryItem{path: path}, opts) do

    client = Map.get(opts, :client, Client)

    client.download(%{path: path}) |> handle
  end

  def get(_item = %InventoryFolder{}, _opts) do
    # folder traversal not yet implemented
  end

  defp handle({:ok, response}) do
    {:ok, %FileData
      {
        content: response.body,
        name: response.headers["file_data"]["name"],
        size: response.headers["file_data"]["size"]
      }
    }
  end

  defp handle({:error, message}) do
    {:error, message}
  end
end
