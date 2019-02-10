defmodule FileSync.Boundaries.DropBox.HttpApi do

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

  defp headers(opts) do
    endpoint = opts.endpoint
    strategy = endpoint.strategy

    [
      "Authorization": "Bearer #{opts.token}"
    ]
    |> Enum.into(strategy.headers(endpoint))
  end

  defp http_options do
    [
      timeout: 8000
    ]
  end

end
