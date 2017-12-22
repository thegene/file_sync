defmodule FileSync.Boundaries.DropBox.FileContents do

  alias FileSync.Data.FileData
  alias FileSync.Boundaries.DropBox.Client

  def get(opts = %{path: path}) do

    client = Map.get(opts, :client, Client)

    client.download(%{path: path}) |> handle
  end

  defp handle({:ok, response}) do
    {:ok, %FileData{
      content: response.body,
      name: response.headers["file_data"]["name"]}
    }
  end

  defp handle({:error, message}) do
    {:error, message}
  end
end
