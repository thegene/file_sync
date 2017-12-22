defmodule FileSync.Boundaries.DropBox.ResponseParsers.ListFolder do

  alias FileSync.Boundaries.DropBox.Response

  def parse(%{status_code: 200, headers: headers, body: body}) do
    %Response{
      status_code: 200,
      headers: Enum.into(headers, %{}),
      body: body |> Poison.decode! |> build_response_body
    }
  end

  def parse(%{status_code: 409, body: body, headers: headers}) do
    %Response{
      status_code: 409,
      headers: Enum.into(headers, %{}),
      body: body |> Poison.decode! |> Map.get("error_summary")
    }
  end

  defp build_response_body(body) do
    %{
      entries: body["entries"]
    }
  end
end
