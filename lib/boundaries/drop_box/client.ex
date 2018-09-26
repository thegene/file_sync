defmodule FileSync.Boundaries.DropBox.Client do
  alias FileSync.Boundaries.DropBox.HttpApi
  alias FileSync.Boundaries.DropBox.Endpoints.{
    ListFolder,
    ListFolderContinue,
    Download
  }
  alias FileSync.Boundaries.DropBox.ResponseParsers

  def list_folder(opts) do
    request(opts, ListFolder, ResponseParsers.ListFolder)
  end

  def list_folder_continue(opts) do
    request(opts, ListFolderContinue, ResponseParsers.ListFolder)
  end

  def download(opts) do
    request(opts, Download, ResponseParsers.Download)
  end

  defp request(opts, endpoint, parser) do
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

  defp post(%{endpoint: endpoint, api: api}) do
    api.post(%{endpoint: endpoint})
  end

  defp inject_endpoint(opts, endpoint) do
    Map.merge(opts, %{endpoint: endpoint.build_endpoint(opts)})
  end

  defp inject_token(opts) do
    require IEx
    IEx.pry
  end

  defp set_defaults(opts) do
    %{api: HttpApi} |> Map.merge(opts)
  end
end
