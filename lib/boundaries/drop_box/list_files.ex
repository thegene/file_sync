defmodule Boundaries.DropBox.ListFiles do

  def try do
    post
    |> Map.get(:body)
    |> Poison.decode!
    |> Map.get("entries")
  end

  defp post do
    HTTPotion.post(url, post_settings)
  end

  defp post_settings do
    [
      body: data,
      headers: headers,
      timeout: 10_000
    ]
  end

  defp token do
    File.read!("tmp/dropbox_token")
    |> String.trim
  end

  defp headers do
    [
      "Authorization": "Bearer #{token}",
      "Content-Type": "application/json" 
    ]
  end

  defp data do
    %{
      "path": "/camera uploads",
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
