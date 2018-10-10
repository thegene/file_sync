defmodule FileSync.Boundaries.DropBox.Client do
  alias FileSync.Boundaries.DropBox.HttpApi
  alias FileSync.Boundaries.DropBox.Endpoints.{
    ListFolder,
    ListFolderContinue,
    Download
  }
  alias FileSync.Boundaries.DropBox.ResponseParsers

  def request(opts, endpoint, parser) do
    opts
    |> set_defaults
    |> inject_endpoint(endpoint)
    |> inject_token
    |> post
    |> handle_response(parser)
  end

  defp handle_response({:error, %{reason: :connect_timeout}}, _parser) do
    {:error, "request timed out"}
  end

  defp handle_response({:ok, %{status_code: 409, body: body}}, _parser) do
    {:error, body |> Poison.decode! |> Map.get("error_summary")}
  end

  defp handle_response({:ok, %{status_code: 400, body: body}}, _parser) do
    {:error, body}
  end

  defp handle_response({:ok, response}, parser) do
    {:ok, response |> parser.parse }
  end

  defp post(opts) do
    opts
    |> Map.take([:endpoint, :token])
    |> opts.api.post
  end

  defp inject_endpoint(opts, endpoint) do
    Map.merge(opts, %{endpoint: endpoint.build_endpoint(opts)})
  end

  defp inject_token(opts = %{token: _token}) do
    opts
  end

  defp set_defaults(opts) do
    %{api: HttpApi} |> Map.merge(opts)
  end
end
