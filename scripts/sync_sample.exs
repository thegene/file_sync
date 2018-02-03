require IEx

alias FileSync.Interactions

from = %Interactions.Source{
  module: %FileSync.Boundaries.DropBox{},
  opts: %{
    folder: "Harrison Birth",
    limit: 3
  }
}

to = %Interactions.Source{
  module: %FileSync.Boundaries.FileSystem{},
  opts: %{
    directory: "data"
  }
}

Interactions.SyncSingleBatch.sync(from: from, to: to)
