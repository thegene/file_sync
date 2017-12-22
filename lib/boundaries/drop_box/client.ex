defmodule FileSync.Boundaries.DropBox.Client do
  alias FileSync.Boundaries.DropBox.{ResponseParser,HttpApi}
  alias FileSync.Boundaries.DropBox.Endpoints.ListFolder

  def list_folder(opts) do
    opts
    |> set_defaults
    |> post
    |> handle_response
  end

  defp handle_response({:ok, response}) do
    response
    |> ResponseParser.parse
    |> respond
  end

  defp handle_response({:error, %{reason: :connect_timeout}}) do
    {:error, "request timed out"}
  end

  defp respond(response = %{status_code: 200}) do
    {:ok, response}
  end

  defp respond(response) do
    {:error, response.body}
  end

  defp post(%{folder: folder, api: api}) do
    api.post(%{
             endpoint: "list_folder",
             endpoint_opts: endpoint_opts(folder)
           })
  end

  defp endpoint_opts(folder) do
    %ListFolder{folder: folder}
  end

  defp set_defaults(opts) do
    %{api: HttpApi} |> Map.merge(opts)
  end
end
