defmodule FileSync.Boundaries.DropBox.FolderOptions do
  alias FileSync.Boundaries.DropBox.FolderOptions

  defstruct [
    :folder,
    recursive: false,
    include_media_info: false,
    include_deleted: false,
    include_has_explicit_shared_members: false,
    include_mounted_folders: true
  ]

  def endpoint_options(%FolderOptions{
      folder: folder,
      recursive: recursive,
      include_media_info: include_media_info,
      include_deleted: include_deleted,
      include_has_explicit_shared_members: include_has_explicit_shared_members,
      include_mounted_folders: include_mounted_folders 
                                    }) do
    %{
      "path": "/#{folder}",
      "recursive": recursive,
      "include_media_info": include_media_info,
      "include_deleted": include_deleted,
      "include_has_explicit_shared_members": include_has_explicit_shared_members,
      "include_mounted_folders": include_mounted_folders
    }
    |> Poison.encode!
  end
end
