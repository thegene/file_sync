defmodule FileSync.Interactions.QueueContentFromInventoryQueueSpec do
  use ESpec

  import Double

  alias FileSync.Interactions.QueueContentFromInventoryQueue

  alias FileSync.Actions.Queue
  alias FileSync.Interactions.Source
  alias FileSync.Data.{InventoryItem,FileData}

  alias FileSync.Boundaries.DropBox

  context "Given an inventory queue and content queue" do
    let inventory_queue: Queue.start_link([]) |> elem(1)
    let content_queue: Queue.start_link([]) |> elem(1)

    it "starts with an empty content queue" do
      content_queue()
      |> Queue.empty?
      |> expect
      |> to(eq(true))
    end

    context "when an item is on the inventory queue" do
      let item: %InventoryItem{path: "somewhere", name: "FooFile.png"}
      let source: %Source{contents: file_contents(), validators: validators()}

      let :mock_logger do
        Logger
        |> double
        |> allow(:info, fn(_msg) -> nil end)
        |> allow(:error, fn(_msg) -> nil end)
      end

      let :opts do
        %{
          logger: mock_logger()
        }
      end

      before do
        inventory_queue()
        |> Queue.push(item())

        inventory_queue()
        |> QueueContentFromInventoryQueue.process(content_queue(), source(), opts())
      end

      context "when we successfully get the contents" do
        let validators: [validator()]

        let :file_contents do
          DropBox.FileContents
          |> double
          |> allow(:get, fn(_data, _opts) -> {:ok, file_data()} end)
        end

        let :file_data do
          %FileData{name: "FooFile.png"}
        end

        context "when validators pass" do
          let :validator do
            DropBox.ContentHashValidator
            |> double
            |> allow(:valid?, fn(res) -> res end)
          end

          it "adds filedata to the content queue" do
            content_queue()
            |> Queue.pop
            |> to(eq(file_data()))
          end

          it "logs a successful enqueue" do
            assert_received({:info, "successfully enqueued content for FooFile.png"})
          end
        end

        context "when validators fail" do
          let :validator do
            DropBox.ContentHashValidator
            |> double
            |> allow(:valid?, fn(_res) -> {:error, "validation failed"} end)
          end

          it "does not add anything to filedata queue" do
            content_queue()
            |> Queue.empty?
            |> expect
            |> to(eq(true))
          end

          it "pushes original item back onto inventory queue" do
            inventory_queue()
            |> Queue.pop
            |> expect
            |> to(eq(item()))
          end

          it "logs a validation error" do
            assert_received({:error,
              "failed getting FooFile.png, will retry: validation failed"})
          end
        end
      end

      context "when getting contents fails" do
        let validators: []

        let :file_contents do
          DropBox.FileContents
          |> double
          |> allow(:get, fn(_data, _opts) -> {:error, "something borked"} end)
        end

        it "adds the inventory item back to the inventory queue" do
          inventory_queue()
          |> Queue.pop
          |> expect
          |> to(eq(item()))
        end

        it "leaves the content queue empty" do
          content_queue()
          |> Queue.empty?
          |> expect
          |> to(eq(true))
        end

        it "logs the error message" do
          assert_received({:error,
            "failed getting FooFile.png, will retry: something borked"})
        end
      end
    end
  end
end
