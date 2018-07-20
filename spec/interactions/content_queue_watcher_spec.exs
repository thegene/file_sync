defmodule FileSync.Interactions.ContentQueueWatcherSpec do
  use ESpec

  import Double

  alias FileSync.Interactions.{
    SaveContentQueueToInventory,
    ContentQueueWatcher,
    Source
  }

  context "Given we want to save content queue to an inventory" do
    before do
      ContentQueueWatcher.check_queue(
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
        SaveContentQueueToInventory
        |> double
        |> allow(:save_to, fn(:mock_content_queue, _source) ->
          {:ok, "hooray"}
        end)
      end

      it "uses the module to save" do
        assert_received({
          :save_to,
          :mock_content_queue,
          %Source{}
        })
      end
    end

    context "but the contained module fails to process" do
      let :mock_module do
        SaveContentQueueToInventory
        |> double
        |> allow(:save_to, fn(:mock_content_queue, _source) ->
          {:error, "oh noe!"}
        end)
      end

      it "logs a failure" do
        assert_received({:warn, "oh noe!"})
      end
    end
  end
end
