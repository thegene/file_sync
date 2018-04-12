require IEx

alias FileSync.Actions.Queue
alias FileSync.Interactions.{Source,QueueContentFromInventoryQueue,BuildInventoryQueue}

alias FileSync.Boundaries.DropBox
alias FileSync.Boundaries.FileSystem

source = %Source{
  contents: DropBox.FileContents,
  validators: [DropBox.ContentHashValidator]
}

{:ok, inventory_queue} = Queue.start_link([])
{:ok, item_queue} = Queue.start_link([])


defmodule Here do
  def iterate_over_inventory_queue(inventory_queue, content_queue, source) do
    inventory_queue
    |> QueueContentFromInventoryQueue.process(content_queue, source, %{logger: Here})

    case inventory_queue |> Queue.empty? do
      true -> IO.puts("DONE!")
      false -> iterate_over_inventory_queue(inventory_queue, content_queue, source)
    end
  end

  def info(message) do
    IO.puts(message)
  end

  def error(message) do
    IO.puts(message)
  end
end

DropBox.Inventory.get(%{folder: "Harrison Birth", limit: 3})
|> BuildInventoryQueue.push_to_queue(inventory_queue)

Here.iterate_over_inventory_queue(inventory_queue, item_queue, source)

IEx.pry

#IEx.pry
#inventory_queue
#|> Queue.pop
#|> Actions.Validator.validate_with([DropBox.ContentHashValidator])
#|> Actions.DirectToQueue.direct(inventory_queue, item_queue)
### above does not work exactly - need to log and then pass item back to DirectToQueue
#### maybe don't even need DirectToQueue ?
#
#item_queue
#|> Queue.pop
#|> FileSync.FileContents.put({directory: 'data'})
#|> Actions.Validator.validate_with([FileSync.FileSizeValidator])
#|> Actions.requeue_failed_save(item_queue)

