alias FileSync.Boundaries.{
  FileSystem,
  DropBox
}

defmodule FileSync.Application do
  use Application

  alias FileSync.Interactions.SyncServer

  def start(_type, _args) do
    source = Application.fetch_env!(:file_sync, :source)
    target = Application.fetch_env!(:file_sync, :target)

    opts = [
      source: build_source(source),
      target: build_target(target)
    ]

    link = SyncServer.start_link(opts)
  end

  defp build_source(source) do
    source_map[source[:source]].build_source(source)
  end

  defp build_target(target) do
    source_map[target[:source]].build_target(target)
  end

  defp source_map do
    %{
      dropbox: DropBox,
      file_system: FileSystem
    }
  end
end
