require IEx

alias FileSync.Interactions.{
  SyncServer,
  Source
}

alias FileSync.Boundaries.{
  FileSystem,
  DropBox
}

source = %Source{
  contents: DropBox.FileContents,
  validators: [DropBox.ContentHashValidator],
  inventory: DropBox.Inventory,
  opts: %{folder: "Harrison Birth", limit: 3},
}

target = %Source{
  contents: FileSystem.Contents,
  validators: [FileSystem.FileSizeValidator],
  opts: %{directory: "data"}
}

{:ok, server} = SyncServer.start_link(source: source, target: target)
IEx.pry
