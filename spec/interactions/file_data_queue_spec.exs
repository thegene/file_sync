defmodule FileSync.Interactions.FileDataQueueSpec do
  use ESpec

  import Double

  alias FileSync.Interactions.{FileDataQueue,Queue}
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
      let :inventory do
        FileContents
        |> double
        |> allow(:get, &(&1))
      end

      before do
        inventory_queue()
        |> FileDataQueue.process_to(file_data_queue(), inventory())
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

      context "and the inventory gets data successfully" do
        let :inventory do
          FileContents
          |> double
          |> allow(:get, fn(_item) -> %FileData{name: "foo"} end)
        end

        before do
          inventory_queue()
          |> FileDataQueue.process_to(file_data_queue(), inventory())
        end

        it "now has this item on the file data queue" do
          file_data_queue()
          |> Queue.pop
          |> expect
          |> to(eq(%FileData{name: "foo"}))
        end
      end
    end
  end
end
