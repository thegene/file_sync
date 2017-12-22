defmodule FileSync.Boundaries.DropBox.Client do
  alias FileSync.Boundaries.DropBox.HttpApi
  alias FileSync.Boundaries.DropBox.Endpoints.{ListFolder,Download}
  alias FileSync.Boundaries.DropBox.ResponseParsers

  def list_folder(opts) do
    opts
    |> set_defaults
    |> inject_endpoint(ListFolder)
    |> post
    |> handle_response(ResponseParsers.ListFolder)
  end

  def download(opts) do
    opts
    |> set_defaults
    |> inject_endpoint(Download)
    |> post
    |> handle_response(ResponseParsers.Download)
  end

  defp handle_response({:error, %{reason: :connect_timeout}}, _parser) do
    {:error, "request timed out"}
  end

  defp handle_response({:ok, response}, parser) do
    response
    |> parser.parse
    |> respond
  end

  defp respond(response = %{status_code: 200}) do
    {:ok, response}
  end

  defp respond(response) do
    {:error, response.body}
  end

  defp post(%{endpoint: endpoint, api: api}) do
    api.post(%{endpoint: endpoint})
  end

  defp inject_endpoint(opts, endpoint) do
    Map.merge(opts, %{endpoint: endpoint.build_endpoint(opts)})
  end

  defp set_defaults(opts) do
    %{api: HttpApi} |> Map.merge(opts)
  end
end
