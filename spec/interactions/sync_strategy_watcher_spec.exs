Code.require_file "mock_logger.exs", "spec"

defmodule FileSync.Interactions.SyncStrategyWatcherSpec do
  use ESpec

  import Double

  alias FileSync.Actions.Queue
  alias FileSync.Interactions.{
    Source,
    SyncStrategyWatcher
  }
  alias FileSync.Boundaries.DropBox.SyncStrategies.Paginate

  alias FileSync.Spec.MockLogger

  context "Given a strategy and an inventory queue" do

    let queue: Queue.start_link |> elem(1)

    let source: %Source{logger: mock_logger(), strategy: mock_strategy()}

    let mock_logger: MockLogger.get_mock()

    context "when checks are successful" do
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

      context "when the watcher polls" do
        before do
          SyncStrategyWatcher.poll(%{}, source(), queue())
        end

        it "checks the source with the given strategy" do

          assert_received({
            :check,
            %{},
            %Source{},
            _queue_pid
          })
        end

        it "logs that it is doing something" do
          assert_received({
            :info,
            "Watching for new files to sync"
          })
        end
      end

      context "when passed the response from the first call" do
        let :last_response do
          SyncStrategyWatcher.poll(%{}, source(), queue())
        end

        it "calls the strategy with the first response" do
          SyncStrategyWatcher.poll(last_response(), source(), queue())

          assert_received({
            :check,
            "foobar",
            %Source{},
            _queue_pid
          })
        end
      end
    end

    context "when there is an error" do
      let :mock_strategy do
        Paginate
        |> double
        |> allow(:check, fn(
            _last_response,
            %Source{},
            _queue
          ) -> {:error, "borked"} end)
      end

      it "logs that an error occurred" do
        SyncStrategyWatcher.poll(%{}, source(), queue())

        assert_received({
          :warn,
          "borked"
        })
      end
    end
  end
end
