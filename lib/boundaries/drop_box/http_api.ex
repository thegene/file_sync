defmodule FileSync.Boundaries.DropBox.HttpApi do
  alias FileSync.Boundaries.DropBox.FolderOptions

  def post(%{endpoint: endpoint, endpoint_opts: opts, http: http}) do
    http.post(
              url(endpoint),
              opts,
              %{},
              %{}
            )
  end

  defp url(endpoint) do
    "https://api.dropboxapi.com/2/files/#{endpoint}"
  end
end
