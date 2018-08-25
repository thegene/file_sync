defmodule FileSync.Boundaries.DropBox.Endpoints.ListFolder do
  alias FileSync.Boundaries.DropBox.Endpoints.ListFolder

  defstruct [
    :folder,
    recursive: false,
    include_media_info: false,
    include_deleted: false,
    include_has_explicit_shared_members: false,
    include_mounted_folders: true,
    optional_params: %{},
    strategy: ListFolder
  ]

  def body(%ListFolder{
      folder: folder,
      recursive: recursive,
      include_media_info: include_media_info,
      include_deleted: include_deleted,
      include_has_explicit_shared_members: include_has_explicit_shared_members,
      include_mounted_folders: include_mounted_folders,
      optional_params: optional_params
  }) do
    %{
      "path": "/#{folder}",
      "recursive": recursive,
      "include_media_info": include_media_info,
      "include_deleted": include_deleted,
      "include_has_explicit_shared_members": include_has_explicit_shared_members,
      "include_mounted_folders": include_mounted_folders
    }
    |> merge_optional(optional_params)
    |> Poison.encode!
  end

  def url(_) do
    "https://api.dropboxapi.com/2/files/list_folder"
  end

  def headers(_) do
    ["Content-Type": "application/json"]
  end

  def build_endpoint(opts) do
    struct_params = opts |> sort_out_optional_params
    struct(ListFolder, struct_params)
  end

  defp sort_out_optional_params(opts) do
    optional = opts |> Map.take(optional_params())
    Map.merge(opts, %{optional_params: optional})
  end

  defp merge_optional(params, optional) do
    params |> Map.merge(optional)
  end

  defp optional_params, do: [:limit]
end
