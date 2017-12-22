defmodule FileSync.Boundaries.DropBox.DownloadOptions do
  defstruct [:path]

  alias FileSync.Boundaries.DropBox.DownloadOptions

  def endpoint_options(%DownloadOptions{path: path}) do
    %{ path: path } |> Poison.encode!
  end
end
