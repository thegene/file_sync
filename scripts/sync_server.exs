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

token = File.read!("tmp/dropbox_token")
        |> String.trim

source = %Source{
  contents: DropBox.FileContents,
  validators: [DropBox.ContentHashValidator],
  inventory: DropBox.Inventory,
  strategy: DropBox.SyncStrategies.Paginate,
  opts: %{
    folder: "Harrison Birth",
    limit: 3,
    token: token
  },
}

target = %Source{
  contents: FileSystem.FileContents,
  validators: [FileSystem.FileSizeValidator],
  opts: %FileSystem.Options{directory: "data"}
}

{:ok, server} = SyncServer.start_link(source: source, target: target)

inventory_queue = FileSync.Actions.Queue.find_queue(:inventory)

IEx.pry
