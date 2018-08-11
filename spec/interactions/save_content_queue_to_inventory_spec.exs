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
    let opts: %{foo: "bar"}

    let source: %Source{
      contents: inventory(),
      opts: opts(),
      validators: [validator()]
    }

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
      |> allow(:valid?, fn(data = %FileData{}, _source) ->
        {:ok, data}
      end)
    end

    let :fail_validator do
      FileSizeValidator
      |> double
      |> allow(:valid?, fn(_data = %FileData{}, _source) ->
        {:error, "File size validation failed!"}
      end)
    end

    let validator: success_validator()

    context "when the queue is empty" do
      let inventory: success_inventory()

      before do
        message = queue() |> SaveContentQueueToInventory.save_to(source())
        {:shared, %{message: message}}
      end

      it "responds with :ok but nil message" do
        shared.message
        |> expect
        |> to(eq({:ok, nil}))
      end
    end

    context "when the queue is not empty" do
      before do
        queue()
        |> Queue.push(item())
      end

      context "when we attempt to put file data to an inventory" do
        before do
          message = queue() |> SaveContentQueueToInventory.save_to(source())
          {:shared, %{message: message}}
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

            it "returns an ok message" do
              shared.message
              |> expect
              |> to(eq({:ok, "Successfully saved foobar.gif"}))
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

            it "returns an error message" do
              shared.message
              |> expect
              |> to(eq({:error, "Failed to save foobar.gif, requeueing: " <>
                "File size validation failed!"}))
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

          it "returns an error message" do
            shared.message
            |> expect
            |> to(eq({:error, "Failed to save foobar.gif, requeueing: Oh no!"}))
          end
        end
      end
    end
  end
end
