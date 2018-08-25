defmodule FileSync.Boundaries.DropBox.Endpoints.ListFolderContinue do
  alias FileSync.Boundaries.DropBox.Endpoints.ListFolderContinue

  defstruct [
    :cursor,
    strategy: ListFolderContinue
  ]

  def build_endpoint(%{cursor: cursor}) do
    %ListFolderContinue{cursor: cursor}
  end

  def headers(%ListFolderContinue{}) do
    ["Content-Type": "application/json"]
  end

  def url(%ListFolderContinue{}) do
    "https://api.dropboxapi.com/2/files/list_folder/continue"
  end

  def body(%ListFolderContinue{cursor: cursor}) do
    %{cursor: cursor}
    |> Poison.encode!
  end
end
