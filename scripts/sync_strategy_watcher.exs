require IEx

alias FileSync.Interactions.{
  Source,
  SyncStrategyWatcher
}

alias FileSync.Actions.Queue

alias FileSync.Boundaries.DropBox.SyncStrategies.Paginate

{:ok, inventory_queue} = Queue.start_link(name: :inventory)

token = File.read!("tmp/dropbox_token")
        |> String.trim

source = %Source{
  strategy: Paginate,
  queue_name: :inventory,
  opts: %{
    folder: "Harrison Birth",
    limit: 5,
    token: token
  }
}

IEx.pry
{:ok, watcher} = SyncStrategyWatcher.start_link(inventory_queue: :inventory, source: source)
state = :sys.get_state(watcher)
IEx.pry

