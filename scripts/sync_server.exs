require IEx

alias FileSync.Interactions.{
  SyncServer,
  Source,
  BuildInventoryQueue
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
  contents: FileSystem.FileContents,
  validators: [FileSystem.FileSizeValidator],
  opts: %FileSystem.Options{directory: "data"}
}

{:ok, server} = SyncServer.start_link(source: source, target: target)

inventory_queue = FileSync.Actions.Queue.find_queue(:inventory)

DropBox.Inventory.get(%{folder: "Harrison Birth", limit: 3})
|> elem(1)
|> BuildInventoryQueue.push_to_queue(inventory_queue)


IEx.pry
