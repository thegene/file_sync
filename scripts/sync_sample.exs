require IEx

alias FileSync.Interactions.SyncSingleBatch

SyncSingleBatch.sync(%{
  from: FileSync.Boundaries.DropBox,
  from_opts: %{
    folder: "Harrison Birth",
    limit: 30
  },
  to: FileSync.Boundaries.FileSystem,
  to_opts: %{
    directory: "data"
  }
})
