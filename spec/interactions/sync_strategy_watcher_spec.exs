defmodule FileSync.Interactions.SyncStrategyWatcherSpec do
  use ESpec

  import Double

  alias FileSync.Actions.Queue
  alias FileSync.Interactions.{
    Source,
    SyncStrategyWatcher
  }
  alias FileSync.Boundaries.DropBox.SyncStrategies.Paginate

  context "Given a strategy and an inventory queue" do
    let :mock_strategy do
      Paginate
      |> double
      |> allow(:check, fn(
          _last_response,
          %Source{},
          _queue
        ) -> {:ok, "foobar"} end)
      |> allow(:check, fn(
          "foobar",
          %Source{},
          _queue
        ) -> {:ok, "blah"} end)
    end

    let queue: Queue.start_link |> elem(1)

    let source: %Source{}

    it "checks the source with the given strategy" do
      SyncStrategyWatcher.poll(%{}, source(), mock_strategy(), queue())

      assert_received({
        :check,
        %{},
        %Source{},
        _queue_pid
      })
    end

    context "when passed the response from the first call" do
      let :last_response do
        SyncStrategyWatcher.poll(%{}, source(), mock_strategy(), queue())
      end

      it "calls the strategy with the first response" do
        SyncStrategyWatcher.poll(last_response(), source(), mock_strategy(), queue())

        assert_received({
          :check,
          "foobar",
          %Source{},
          _queue_pid
        })
      end
    end
  end
end
