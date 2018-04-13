defmodule FileSync.Interactions.SaveContentQueueToInventorySpec do
  use ESpec

  import Double

  alias FileSync.Actions.Queue
  alias FileSync.Data.FileData
  alias FileSync.Interactions.{SaveContentQueueToInventory,Source}
  alias FileSync.Boundaries.FileSystem.{FileContents,FileSizeValidator}

  context "Given a queue with a FileData item" do
    let queue: Queue.start_link([]) |> elem(1)
    let item: %FileData{name: "foobar.gif"}
    let dependencies: %{logger: mock_logger()}
    let opts: %{foo: "bar"}

    let source: %Source{
      contents: inventory(),
      opts: opts(),
      validators: [validator()]
    }

    let :mock_logger do
      Logger
      |> double
      |> allow(:info, fn(_msg) -> :ok end)
      |> allow(:error, fn(_msg) -> :ok end)
    end

    let :success_inventory do
      FileContents
      |> double
      |> allow(:put, fn(data = %FileData{}, _opts) -> {:ok, data} end)
    end

    let :fail_inventory do
      FileContents
      |> double
      |> allow(:put, fn(_data = %FileData{}, _opts) -> {:error, "Oh no!"} end)
    end

    let :success_validator do
      FileSizeValidator
      |> double
      |> allow(:valid?, fn(data = %FileData{}) ->
        {:ok, data}
      end)
    end

    let :fail_validator do
      FileSizeValidator
      |> double
      |> allow(:valid?, fn(_data = %FileData{}) ->
        {:error, "File size validation failed!"}
      end)
    end

    let validator: success_validator()

    before do
      queue()
      |> Queue.push(item())
    end

    context "when we attempt to put file data to an inventory" do
      before do
        queue() |> SaveContentQueueToInventory.save_to(source(), dependencies())
      end

      let inventory: success_inventory()

      it "calls #put" do
        assert_received({:put, %FileData{}, %{foo: "bar"}})
      end

      context "and it is successful" do
        let inventory: success_inventory()

        context "and validations pass" do
          let validator: success_validator()

          it "removes the item from the queue" do
            queue()
            |> Queue.empty?
            |> expect
            |> to(eq(true))
          end

          it "logs that it was successful" do
            assert_received({:info, "Successfully saved foobar.gif"})
          end
        end

        context "but validations fail" do
          let validator: fail_validator()

          it "replaces the item back onto the queue" do
            queue()
            |> Queue.pop
            |> expect
            |> to(eq(item()))
          end

          it "logs that it errored" do
            assert_received({:error, "Failed to save foobar.gif, requeueing: File size validation failed!"})
          end
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

        it "logs that it errored" do
          assert_received({:error, "Failed to save foobar.gif, requeueing: Oh no!"})
        end
      end
    end
  end
end
