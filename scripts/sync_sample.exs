require IEx

alias FileSync.Interactions.SyncSample

SyncSample.sync(%{
  from: FileSync.Boundaries.DropBox,
  from_opts: %{
    folder: "Harrison Birth",
    limit: 5
  },
  to: FileSync.Boundaries.FileSystem,
  to_opts: %{
    directory: "data"
  }
})
