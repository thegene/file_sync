require IEx

alias FileSync.Interactions
alias Interactions.Queue
alias FileSync.Boundaries.DropBox

from = %Interactions.Source{
  module: %FileSync.Boundaries.DropBox{},
  opts: %{
    folder: "Harrison Birth",
    limit: 30
  }
}

to = %Interactions.Source{
  module: %FileSync.Boundaries.FileSystem{},
  opts: %{
    directory: "data"
  }
}

{:ok, inventory_queue} = Interactions.Queue.start_link([])
{:ok, item_queue} = Interactions.Queue.start_link([])

DropBox.Inventory.get(%{folder: "Harrison Birth", limit: 3})
|> Interactions.InventoryQueue.push_to_queue(inventory_queue)

inventory_queue
|> Interactions.BuildFileDataQueue.process_to(
  item_queue,
  DropBox.FileContents,
  [DropBox.ContentHashValidator]
)

IEx.pry
