defmodule FileSync.Boundaries.DropBox.HttpApi do
  alias FileSync.Boundaries.DropBox.Endpoints.{ListFolder, Download}

  def post(opts = %{
             endpoint: endpoint
           }) do

    http = Map.get(opts, :http, HTTPoison)

    strategy = endpoint.strategy

    http.post(
              strategy.url(endpoint),
              strategy.body(endpoint),
              headers(opts),
              http_options()
            )
  end

  defp token_from_file do
    File.read!("tmp/dropbox_token")
    |> String.trim
  end

  defp headers(opts) do
    token = Map.get(opts, :token, token_from_file())
    endpoint = opts.endpoint
    strategy = endpoint.strategy

    [
      "Authorization": "Bearer #{token}",
      "Content-Type": "application/json"
    ]
    |> Enum.into(strategy.headers(endpoint))
  end

  defp http_options do
    [
      timeout: 8000
    ]
  end

end
