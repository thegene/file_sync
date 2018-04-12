require IEx

alias FileSync.Actions
alias Actions.Queue
alias FileSync.Boundaries.DropBox
alias FileSync.Boundaries.FileSystem


{:ok, inventory_queue} = Queue.start_link([])
{:ok, item_queue} = Queue.start_link([])

DropBox.Inventory.get(%{folder: "Harrison Birth", limit: 3})
|> Actions.BuildInventoryQueue.push_to_queue(inventory_queue)

# these actions should act on individual items, and should loop over each in a separate action
inventory_queue
|> Actions.BuildFileDataQueue.process_to(
  item_queue,
  DropBox.FileContents,
  [DropBox.ContentHashValidator]
)

IEx.pry
inventory_queue
|> Queue.pop
|> Actions.Validator.validate_with([DropBox.ContentHashValidator])
|> Actions.DirectToQueue.direct(inventory_queue, item_queue)
## above does not work exactly - need to log and then pass item back to DirectToQueue
### maybe don't even need DirectToQueue ?

item_queue
|> Queue.pop
|> FileSync.FileContents.put({directory: 'data'})
|> Actions.Validator.validate_with([FileSync.FileSizeValidator])
|> Actions.requeue_failed_save(item_queue)
