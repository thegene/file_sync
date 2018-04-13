defmodule FileSync.Interactions.SaveContentQueueToInventorySpec do
  use ESpec

  import Double

  alias FileSync.Actions.Queue
  alias FileSync.Data.FileData
  alias FileSync.Interactions.SaveContentQueueToInventory
  alias FileSync.Boundaries.FileSystem.FileContents

  context "Given a queue with a FileData item" do
    let queue: Queue.start_link([]) |> elem(1)

    let item: %FileData{name: "foobar.gif"}

    before do
      queue()
      |> Queue.push(item())
    end

    context "when we attempt to put file data to an inventory" do
      before do
        queue() |> SaveContentQueueToInventory.save_to(inventory(), opts())
      end

      let opts: %{foo: "bar"}

      let :success_inventory do
        FileContents
        |> double
        |> allow(:put, fn(_data = %FileData{}, _opts) -> {:ok, "Hooray!"} end)
      end

      let :fail_inventory do
        FileContents
        |> double
        |> allow(:put, fn(_data = %FileData{}, _opts) -> {:error, "Oh no!"} end)
      end

      let inventory: success_inventory()

      it "calls #put" do
        assert_received({:put, %FileData{}, %{foo: "bar"}})
      end

      context "and it is successful" do
        let inventory: success_inventory()

        it "removes the item from the queue" do
          queue()
          |> Queue.empty?
          |> expect
          |> to(eq(true))
        end

      end

      context "and it fails" do
        let inventory: fail_inventory()

        it "replaces the item back onto the queue" do
          queue()
          |> Queue.pop
          |> expect
          |> to(eq(item()))
        end

      end
    end
  end
end
