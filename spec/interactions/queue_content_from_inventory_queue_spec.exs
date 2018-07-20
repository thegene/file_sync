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
    let source: %Source{}

    let :passing_validator do
      DropBox.ContentHashValidator
      |> double
      |> allow(:valid?, fn(res, _source) -> {:ok, res} end)
    end

    let :failing_validator do
      DropBox.ContentHashValidator
      |> double
      |> allow(:valid?, fn(_res, _source) -> {:error, "validation failed"} end)
    end

    it "starts with an empty content queue" do
      content_queue()
      |> Queue.empty?
      |> expect
      |> to(eq(true))
    end

    context "when an item is on the inventory queue" do
      let source: %Source{contents: file_contents(), validators: validators()}
      let item: %InventoryItem{path: "somewhere", name: "FooFile.png"}

      before do
        inventory_queue()
        |> Queue.push(item())

        message = inventory_queue()
        |> QueueContentFromInventoryQueue.process(content_queue(), source())

        {:shared, %{message: message}}
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
          let validator: passing_validator()

          it "adds filedata to the content queue" do
            content_queue()
            |> Queue.pop
            |> to(eq(file_data()))
          end

          it "returns a success message" do
            shared.message
            |> expect
            |> to(eq({:ok, "Successfully enqueued content for FooFile.png"}))
          end
        end

        context "when validators fail" do
          let validator: failing_validator()

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

          it "returns an error message" do
            shared.message
            |> expect
            |> to(eq({:error, "Failed getting FooFile.png, " <>
              "will retry: validation failed"}))
          end
        end
      end

      context "when getting contents fails" do
        let :file_contents do
          DropBox.FileContents
          |> double
          |> allow(:get, fn(_data, _opts) -> {:error, "something borked"} end)
        end

        context "when there are no validators" do
          let validators: []

          it "returns an error message" do
            shared.message
            |> expect
            |> to(eq({:error, "Failed getting FooFile.png, " <>
              "will retry: something borked"}))
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
        end

        context "when there is a validator" do
          let validators: [passing_validator()]

          it "returns an error message" do
            shared.message
            |> expect
            |> to(eq({:error, "Failed getting FooFile.png, " <>
              "will retry: something borked"}))
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
        end
      end
    end

    context "when inventory queue is empty" do
      before do
        message = inventory_queue()
        |> QueueContentFromInventoryQueue.process(content_queue(), source())

        {:shared, %{message: message}}
      end

      it "is ok but nil" do
        shared.message
        |> expect
        |> to(eq({:ok, "Inventory queue is empty"}))
      end
    end
  end
end
