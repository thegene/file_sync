defmodule FileSync.Boundaries.DropBox.FileContents do

  alias FileSync.Data.FileData

  def get(%{path: path, client: client}) do
    client.download(%{path: path}) |> handle
  end

  defp handle({:ok, response}) do
    {:ok, %FileData{content: response.body}}
  end
end
