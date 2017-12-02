defmodule FileSync.Boundaries.DropBox.Client do
  alias FileSync.Boundaries.DropBox.ParseResponse

  def list_folder(opts) do
    default_post_opts
    |> Map.merge(opts)
    |> post
    |> ParseResponse.from_httpoison
    |> respond
  end

  defp respond(response) do
    {:ok, response}
  end

  defp default_post_opts do
    %{
      http: HTTPoison
    }
  end

  defp post(%{folder: folder, http: http}) do
    http.post(
              url(),
              body(folder),
              headers(),
              options()
            )
  end

  defp options do
    [
      timeout: 8000
    ]
  end

  defp token do
    File.read!("tmp/dropbox_token")
    |> String.trim
  end

  defp headers do
    [
      "Authorization": "Bearer #{token()}",
      "Content-Type": "application/json" 
    ]
  end

  defp body(folder) do
    %{
      "path": "/#{folder}",
      "recursive": false,
      "include_media_info": false,
      "include_deleted": false,
      "include_has_explicit_shared_members": false,
      "include_mounted_folders": true
    }
    |> Poison.encode!
  end

  defp url do
    "https://api.dropboxapi.com/2/files/list_folder"
  end
end
