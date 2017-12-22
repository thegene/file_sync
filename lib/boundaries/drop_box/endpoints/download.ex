defmodule FileSync.Boundaries.DropBox.Endpoints.Download do
  defstruct [:path]

  alias FileSync.Boundaries.DropBox.Endpoints.Download

  def endpoint_options(%Download{path: path}) do
    %{ path: path } |> Poison.encode!
  end
end
