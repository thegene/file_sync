defmodule FileSync.Interactions.InventoryQueueWatcherSpec do
  use ESpec

  import Double

  alias FileSync.Interactions.{
    QueueContentFromInventoryQueue
    InventoryQueueWatcher,
    Source
  }

  context "Given we want to check an inventory queue" do
    before do
      InventoryQueueWatcher.check_queue(
        :mock_inventory_queue,
        :mock_content_queue,
        source(),
        mock_module()
      )
    end

    let source: %Source{logger: mock_logger()}
    let :mock_logger do
      Logger
      |> double
      |> allow(:warn, fn(_msg) -> nil end)
    end

    context "and the contained module successfully processes" do
      let :mock_module do
        QueueContentFromInventoryQueue
        |> double
        |> allow(:process, fn(_inventory_queue, _content_queue, _source) ->
          {:ok, "hooray!"}
        end)
      end

      it "uses the contained module to process the queue" do
        assert_received(
          {
            :process,
            :mock_inventory_queue,
            :mock_content_queue,
            %Source{}
          }
        )
      end
    end

    context "but the contained module fails to process" do
      let :mock_module do
        QueueContentFromInventoryQueue
        |> double
        |> allow(:process, fn(_inventory_queue, _content_queue, _source) ->
          {:error, "oh no"}
        end)
      end

      it "logs a failure" do
        assert_received({:warn, "oh no"})
      end
    end
  end
end
