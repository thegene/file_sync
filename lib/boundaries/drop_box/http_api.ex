defmodule FileSync.Boundaries.DropBox.HttpApi do
  alias FileSync.Boundaries.DropBox.{ListFolderOptions, DownloadOptions}

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

  defp url(endpoint) do
    "https://api.dropboxapi.com/2/files/#{endpoint}"
  end

  defp token_from_file do
    File.read!("tmp/dropbox_token")
    |> String.trim
  end

  defp body(endpoint_options = %ListFolderOptions{}) do
    ListFolderOptions.endpoint_options(endpoint_options)
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
