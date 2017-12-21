defmodule FileSync.Boundaries.DropBox.HttpApi do

  def post(opts = %{
             endpoint: endpoint,
             endpoint_opts: endpoint_opts
           }) do

    http = Map.get(opts, :http, HTTPoison)

    http.post(
              url(endpoint),
              body(endpoint_opts),
              headers(opts),
              %{}
            )
  end

  defp url(endpoint) do
    "https://api.dropboxapi.com/2/files/#{endpoint}"
  end

  defp token_from_file do
    File.read!("tmp/dropbox_token")
    |> String.trim
  end

  defp body(endpoint_options) do
    endpoint_options
  end

  defp headers(opts) do
    token = Map.get(opts, :token, token_from_file())

    [
      "Authorization": "Bearer #{token}",
      "Content-Type": "application/json"
    ]
  end
end
