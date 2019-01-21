require IEx

alias FileSync.Interactions.{
  Source,
  SyncStrategyWatcher
}

alias FileSync.Actions.Queue

alias FileSync.Boundaries.DropBox.SyncStrategies.Paginate
alias FileSync.Boundaries.DropBox.{
  Options,
  TokenFinder
}

{:ok, inventory_queue} = Queue.start_link(name: :inventory)

options = %Options{
  folder: "Harrison Birth",
  limit: 5,
  token_file_path: "tmp/dropbox_token"
} |> TokenFinder.find

source = %Source{
  strategy: Paginate,
  queue_name: :inventory,
  opts: options
}

IEx.pry
{:ok, watcher} = SyncStrategyWatcher.start_link(inventory_queue: :inventory, source: source)
state = :sys.get_state(watcher)
IEx.pry

