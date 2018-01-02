require IEx

alias FileSync.Interactions.SyncSample

SyncSample.sync(%{
  from: FileSync.Boundaries.DropBox,
  from_opts: %{
    folder: "Harrison Birth",
    limit: 1
  },
  #  to: FileSync.Boundaries.FileSystem.Inventory,
  #  to_opts: %{
  #    directory: "data"
  #  }
})
