defmodule FileSync.Interactions.SyncStrategyPollerSpec do
  use ESpec

  import Double

  alias FileSync.Actions.Queue
  alias FileSync.Interactions.{
    Source,
    SyncStrategyPoller
  }
  alias FileSync.Boundaries.DropBox.SyncStrategies.Paginate

  context "Given a strategy and an inventory queue" do
    let :mock_strategy do
      Paginate
      |> double
      |> allow(:check, fn(_anything) -> {:ok, "foobar"} end
       )
    end

    let queue: Queue.start_link |> elem(1)

    let source: %Source{}

    it "checks the source with the given strategy" do
      SyncStrategyPoller.poll(source(), mock_strategy(), queue())

      assert_received({:check})
    end
  end
end
