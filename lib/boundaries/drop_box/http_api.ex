defmodule FileSync.Boundaries.DropBox.HttpApi do
  alias FileSync.Boundaries.DropBox.{ListFolder, DownloadOptions}

  def post(opts = %{
             endpoint: endpoint,
             endpoint_opts: endpoint_opts
           }) do

    http = Map.get(opts, :http, HTTPoison)

    http.post(
              url(endpoint),
              body(endpoint_opts),
              headers(opts),
              http_options(opts)
            )
  end

  defp url("list_folder") do
    "https://api.dropboxapi.com/2/files/list_folder"
  end

  defp url("download") do
    "https://content.dropboxapi.com/2/files/download"
  end

  defp token_from_file do
    File.read!("tmp/dropbox_token")
    |> String.trim
  end

  defp body(endpoint_options = %ListFolder{}) do
    ListFolder.endpoint_options(endpoint_options)
  end

  defp body(endpoint_options = %DownloadOptions{}) do
    DownloadOptions.endpoint_options(endpoint_options)
  end

  defp headers(opts) do
    token = Map.get(opts, :token, token_from_file())

    [
      "Authorization": "Bearer #{token}",
      "Content-Type": "application/json"
    ]
  end

  defp http_options(_opts) do
    [
      timeout: 8000
    ]
  end

end
