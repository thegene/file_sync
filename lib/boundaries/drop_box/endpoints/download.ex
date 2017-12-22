defmodule FileSync.Boundaries.DropBox.Endpoints.Download do
  defstruct [:path]

  alias FileSync.Boundaries.DropBox.Endpoints.Download

  def url(_) do
    "https://content.dropboxapi.com/2/files/download"
  end

  def body(_) do
    ""
  end

  def headers(%Download{path: path}) do
    ["Dropbox-API-Arg": encode_path_header(path)]
  end

  defp encode_path_header(path) do
    %{ path: path } |> Poison.encode!
  end

  def build_endpoint(opts) do
    struct(Download, opts)
  end
end
