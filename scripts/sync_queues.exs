require IEx

alias FileSync.Actions
alias Actions.Queue
alias FileSync.Boundaries.DropBox

{:ok, inventory_queue} = Queue.start_link([])
{:ok, item_queue} = Queue.start_link([])

DropBox.Inventory.get(%{folder: "Harrison Birth", limit: 3})
|> Actions.BuildInventoryQueue.push_to_queue(inventory_queue)

inventory_queue
|> Actions.BuildFileDataQueue.process_to(
  item_queue,
  DropBox.FileContents,
  [DropBox.ContentHashValidator]
)

IEx.pry
