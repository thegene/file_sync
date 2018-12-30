defmodule FileSync.Interactions.SyncServer do
  use Supervisor

  require IEx

  alias FileSync.Actions.Queue
  alias FileSync.Interactions.{
    ContentQueueWatcher,
    InventoryQueueWatcher,
    SyncStrategyWatcher
  }

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, strategy: :one_for_one)
  end

  @impl true
  def init(opts) do
    build_map_from_opts(opts)
    |> Supervisor.init(strategy: :one_for_one)
  end

  defp build_map_from_opts(opts) do
    source = opts |> Keyword.get(:source)
    target = opts |> Keyword.get(:target)

    [
      inventory_queue_spec(source),
      content_queue_spec(target),
      {
        InventoryQueueWatcher,
        inventory_queue: :inventory,
        content_queue: :content,
        source: source
      },
      {
        ContentQueueWatcher,
        content_queue: :content,
        target: target
      },
      {
        SyncStrategyWatcher,
        inventory_queue: :inventory,
        source: source
      }
    ]
  end

  defp inventory_queue_spec(source) do
    %{
      id: :inventory,
      start: {
        Queue,
        :start_link,
        [[name: source.queue_name || :inventory]]
      }
    }
  end

  defp content_queue_spec(target) do
    %{
      id: :content,
      start: {
        Queue,
        :start_link,
        [[name: target.queue_name || :content]]
      }
    }
  end
end
