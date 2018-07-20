require IEx

alias FileSync.Actions.Queue
alias FileSync.Interactions.{
  Source,
  InventoryQueueWatcher,
}

alias FileSync.Boundaries.DropBox
alias FileSync.Boundaries.FileSystem

{:ok, inventory_queue} = Queue.start_link([])
{:ok, item_queue} = Queue.start_link([])

source = %Source{
  contents: DropBox.FileContents,
  validators: [DropBox.ContentHashValidator],
  inventory: DropBox.Inventory,
  opts: %{folder: "Harrison Birth", limit: 3},
}

{:ok, watcher} = InventoryQueueWatcher.start_link(inventory_queue, item_queue, source)

IEx.pry
