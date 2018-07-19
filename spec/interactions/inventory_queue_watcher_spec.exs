defmodule FileSync.Interactions.InventoryQueueWatcherSpec do
  use ESpec

  import Double

  alias FileSync.Interactions.QueueContentFromInventoryQueue
  alias FileSync.Interactions.InventoryQueueWatcher
  alias FileSync.Interactions.Source

  context "Given we want to check an inventory queue" do
    let :mock_module do
      QueueContentFromInventoryQueue
      |> double
      |> allow(:process, fn(_inventory_queue, _content_queue, _source) ->
        {:ok, "hooray!"}
      end)
    end

    let source: %Source{}

    it "uses the contained module to process the queue" do
      InventoryQueueWatcher.check_queue(
        :mock_inventory_queue,
        :mock_content_queue,
        source(),
        mock_module()
      )
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
end
