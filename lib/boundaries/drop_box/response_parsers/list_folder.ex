defmodule FileSync.Boundaries.DropBox.ResponseParsers.ListFolder do

  alias FileSync.Boundaries.DropBox.Response

  def parse(%{status_code: 200, headers: headers, body: body}) do
    %Response{
      status_code: 200,
      headers: Enum.into(headers, %{}),
      body: body |> Poison.decode! |> build_response_body
    }
  end

  defp build_response_body(body) do
    %{
      entries: body["entries"],
      cursor: body["cursor"],
      has_more: body["has_more"]
    }
  end
end
