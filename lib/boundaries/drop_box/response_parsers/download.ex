defmodule FileSync.Boundaries.DropBox.ResponseParsers.Download do
  
  alias FileSync.Boundaries.DropBox.Response

  def parse(%{status_code: 200, headers: headers, body: body}) do
    %Response{
      status_code: 200,
      headers: Enum.into(headers, %{}) |> format_file_headers,
      body: body
    }
  end

  defp format_file_headers(headers) do
    decoded = headers["dropbox-api-result"] |> Poison.decode!
    Map.put(headers, "file_data", decoded)
  end
end
