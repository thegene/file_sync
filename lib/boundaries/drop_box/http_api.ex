defmodule FileSync.Boundaries.DropBox.HttpApi do
  alias FileSync.Boundaries.DropBox.Endpoints.{ListFolder, Download}

  def post(opts = %{
             endpoint: endpoint,
           }) do

    http = Map.get(opts, :http, HTTPoison)

    http.post(
              endpoint.url(opts),
              endpoint.body(opts),
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
