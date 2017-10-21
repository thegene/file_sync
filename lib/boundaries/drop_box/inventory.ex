defmodule FileSync.Boundaries.DropBox.Inventory do

  def get(opts) do
    opts
    |> Enum.into(default_post_opts())
    |> post
    |> parse_response
    |> cast_entries
    |> build_return_struct
  end

  defp build_return_struct(entries) do
    {:ok, %{
      items: entries
    }}
  end

  defp cast_entries(entries) do
    entries
    |> Enum.map(fn(entry) -> cast_single_entry(entry) end)
  end

  defp cast_single_entry(entry) do
    %FileSync.Data.InventoryItem {
      name: entry["name"],
      size: entry["size"]
    }
  end

  defp parse_response(response) do
    response
    |> Map.get(:body)
    |> Poison.decode!
    |> Map.get("entries")
  end

  defp default_post_opts do
    %{
      http: HTTPotion
    }
  end

  defp post(%{http: http, folder: folder}) do
    http.post(url(), post_settings(%{folder: folder}))
  end

  defp post_settings(opts) do
    [
      body: data(opts),
      headers: headers(),
      timeout: 10_000
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

  defp data(%{folder: folder}) do
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
