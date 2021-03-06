defmodule FileSync.Interactions.BuildInventoryQueueSpec do
  use ESpec

  alias FileSync.Actions.Queue
  alias FileSync.Interactions.BuildInventoryQueue
  alias FileSync.Data.{InventoryFolder,InventoryItem}

  context "Given a queue and a successful inventory response" do
    let queue: Queue.start_link([]) |> elem(1)
    let :inventory_response do
      [
        %InventoryItem{name: "some item"},
        %InventoryFolder{}
      ]
    end

    it "starts empty for sanity" do
      queue()
      |> Queue.empty?
      |> expect
      |> to(be_true())
    end

    context "when we add to the queue" do
      before do
        inventory_response() |> BuildInventoryQueue.push_to_queue(queue())
      end

      let :inventory_item do
        queue()
        |> Queue.pop
      end

      it "is no longer empty" do
        queue()
        |> Queue.empty?
        |> expect
        |> not_to(be_true())
      end

      it "contains the inventory item" do
        inventory_item()
        |> Map.get(:name)
        |> expect
        |> to(eq("some item"))
      end

      it "does not contain the folder" do
        inventory_item()
        queue()
        |> Queue.empty?
        |> expect
        |> to(be_true())
      end
    end
  end
end
