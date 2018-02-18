defmodule FileSync.Interactions.InventoryQueueSpec do
  use ESpec

  alias FileSync.Interactions.{Queue,InventoryQueue}
  alias FileSync.Data.{InventoryFolder,InventoryItem}

  context "Given a queue and a successful inventory response" do
    let queue: Queue.start_link([])
    let :inventory_response do
      {:ok, [
        %InventoryItem{name: "some item"},
        %InventoryFolder{}
      ]}
    end

    it "starts empty for sanity" do
      queue()
      |> elem(1)
      |> Queue.empty?
      |> expect
      |> to(be_true())
    end

    context "when we add to the queue" do
      before do
        inventory_response() |> InventoryQueue.push_to_queue(queue())
      end

      let :inventory_item do
        queue()
        |> elem(1)
        |> Queue.pop
      end

      it "is no longer empty" do
        queue()
        |> elem(1)
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
        |> elem(1)
        |> Queue.empty?
        |> expect
        |> to(be_true())
      end
    end
  end
end
