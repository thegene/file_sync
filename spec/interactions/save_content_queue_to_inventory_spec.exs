defmodule FileSync.Interactions.SaveContentQueueToInventorySpec do
  use ESpec

  import Double

  alias FileSync.Actions.Queue
  alias FileSync.Data.FileData
  alias FileSync.Interactions.SaveContentQueueToInventory
  alias FileSync.Boundaries.FileSystem.FileContents

  context "Given a queue with a FileData item" do
    let queue: Queue.start_link([]) |> elem(1)

    let item: %FileData{}

    before do
      queue()
      |> Queue.push(item())
    end

    context "when we successfully put it to an inventory" do
      let :inventory do
        FileContents
        |> double
        |> allow(:put, fn(_data = %FileData{}, _opts) -> {:ok, "Hooray!"} end)
      end

      let opts: %{foo: "bar"}

      before do
        queue() |> SaveContentQueueToInventory.save_to(inventory(), opts())
      end

      it "removes the item from the queue" do
        queue()
        |> Queue.empty?
        |> expect
        |> to(eq(true))
      end

      it "calls #put" do
        assert_received({:put, %FileData{}, %{foo: "bar"}})
      end
    end
  end
end
