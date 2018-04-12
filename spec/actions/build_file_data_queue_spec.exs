defmodule FileSync.Actions.BuildFileDataQueueSpec do
  use ESpec

  import Double

  alias FileSync.Actions.{BuildFileDataQueue,Queue}
  alias FileSync.Data.{InventoryItem,FileData}
  alias FileSync.Boundaries.DropBox.FileContents

  context "Given a queue with InventoryItems and an empty file data queue" do
    let inventory_queue: Queue.start_link([]) |> elem(1)
    let file_data_queue: Queue.start_link([]) |> elem(1)

    it "for sanity starts with an empty file data queue" do
      file_data_queue()
      |> Queue.empty?
      |> expect
      |> to(be_true())
    end

    context "when we process an empty inventory queue" do
      let :contents do
        FileContents
        |> double
        |> allow(:get, &(&1))
      end

      before do
        inventory_queue()
        |> BuildFileDataQueue.process_to(file_data_queue(), contents())
      end

      it "still has an empty data queue" do
        file_data_queue()
        |> Queue.empty?
        |> expect
        |> to(be_true())
      end
    end

    context "when there is an inventory item" do
      before do
        inventory_queue()
        |> Queue.push(%InventoryItem{path: "foo"})
      end

      let! :response do
        inventory_queue()
        |> BuildFileDataQueue.process_to(file_data_queue(), contents())
      end

      context "and the inventory gets data successfully" do
        let :contents do
          FileContents
          |> double
          |> allow(:get, fn(_item) -> {:ok, %FileData{name: "foo"}} end)
        end

        it "now has this item on the file data queue" do
          file_data_queue()
          |> Queue.pop
          |> expect
          |> to(eq(%FileData{name: "foo"}))
        end

        it "now has an empty inventory queue" do
          inventory_queue()
          |> Queue.empty?
          |> expect
          |> to(be_true())
        end

        it "returns an :ok message" do
          {:ok, message} = response()
          message
          |> expect
          |> to(eq("Successfully queued foo"))
        end
      end

      context "and the contents fails to get data successfully" do
        let :contents do
          FileContents
          |> double
          |> allow(:get, fn(_item) -> {:error, "something borked"} end)
        end

        it "still has an empty file data queue" do
          file_data_queue()
          |> Queue.pop
          |> expect
          |> to(be_nil())
        end

        it "still has the original inventory item on the inventory queue" do
          inventory_queue()
          |> Queue.pop
          |> expect
          |> to(eq(%InventoryItem{path: "foo"}))
        end

        it "returns an error message" do
          {:error, message} = response()
          message
          |> expect
          |> to(eq("something borked"))
        end
      end
    end
  end
end
