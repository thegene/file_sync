defmodule FileSync.Boundaries.DropBox.ParseResponse do
  alias FileSync.Boundaries.DropBox.Response

  def from_httpoison(%{
                       status_code: code,
                       headers: headers,
                       body: body
                      }) do
    %Response{
      status_code: code,
      headers: parse_headers(headers),
      body: parse_response_body(body)
    }
  end

  defp parse_headers(headers) do
    Enum.into(headers, %{})
  end

  defp parse_response_body(body) do
    body
    |> Poison.decode!
    |> build_response_body
  end

  defp build_response_body(body) do
    %{
      entries: body["entries"]
    }
  end
end
