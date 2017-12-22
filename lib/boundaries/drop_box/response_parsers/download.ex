defmodule FileSync.Boundaries.DropBox.ResponseParsers.Download do
  
  alias FileSync.Boundaries.DropBox.Response

  def parse(%{status_code: 200, headers: headers, body: body}) do
    %Response{
      status_code: 200,
      headers: Enum.into(headers, %{}),
      body: body
    }
  end
end
