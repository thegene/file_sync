defmodule FileSync.Interactions.SyncServerSpec do
  use ESpec
  require IEx

  alias FileSync.Interactions.SyncServer
  alias FileSync.Interactions.Source
  alias FileSync.Actions.Queue
  alias FileSync.Boundaries.{DropBox, FileSystem}
  alias FileSync.Data.{InventoryItem, FileData}

  import Double

  xcontext "Given a source and a target source" do
    before do
      SyncServer.sync(source: source(), target: target())
    end

    let source: %Source{
      inventory: mock_inventory(),
      opts: source_opts(),
      contents: mock_db_contents(),
      validators: source_validators(),
      queue_name: :source_queue,
      logger: mock_logger()
    }

    let target: %Source{
      queue_name: :target_queue,
      contents: mock_fs_contents(),
      validators: target_validators(),
      opts: target_opts(),
      logger: mock_logger()
    }

    let source_opts: %{
      folder: "foo"
    }

    let target_opts: %FileSystem.Options{
      directory: "bar"
    }

    let mock_db_contents: %{}
    let mock_fs_contents: %{}

    let :mock_logger do
      Logger
      |> double
      |> allow(:warn, fn(_) -> nil end)
    end

    let :failing_validator do
      FileSystem.FileSizeValidator
      |> double
      |> allow(:valid?, fn(_data, _source) -> {:error, "ka-bork"} end)
    end

    let :passing_validator do
      DropBox.ContentHashValidator
      |> double
      |> allow(:valid?, fn(data, _source) -> {:ok, data} end)
    end

    let source_validators: []
    let target_validators: []

    let :content_queue do
      Process.sleep(1) # sometimes the agent process is not ready yet
      Queue.find_queue(:target_queue)
    end

    let :inventory_queue do
      Process.sleep(1) # sometimes the agent process is not ready yet
      Queue.find_queue(:target_queue)
    end

    context "when the inventory successfully returns items" do
      let :mock_inventory do
        DropBox.Inventory
        |> double
        |> allow(:get, fn(%{folder: "foo"}) ->
          {:ok, [%InventoryItem{path: "foo", name: "foobar"}]}
        end)
      end

      context "and file contents successfully fetches file data" do
        let :mock_fs_contents do
          FileSystem.FileContents
          |> double
          |> allow(:put, fn(
                     %FileData{name: "foo.png"},
                     %FileSystem.Options{directory: "bar"}) ->
            {:ok, %FileData{}}
          end)
        end

        let :mock_db_contents do
          DropBox.FileContents
          |> double
          |> allow(:get, fn(%InventoryItem{path: "foo"}, %{folder: "foo"}) ->
            {:ok, %FileData{name: "foo.png"}}
          end)
        end

        context "and validation passes" do
          let source_validators: [passing_validator()]

          it "sends the file contents to the target source" do
            assert_received({
              :put,
              %FileData{},
              %FileSystem.Options{}
            })
          end
        end

        context "but validation fails" do
          let source_validators: [failing_validator()]

          it "does not send the file contents to the target source" do
            refute_received({
              :put,
              %FileData{},
              %FileSystem.Options{}
            })
          end

          it "logs the error message" do
            assert_received({:warn, "Failed getting foobar, will retry: ka-bork"})
          end
        end
      end

      context "and file contents fails to get file data" do
        let :mock_db_contents do
          DropBox.FileContents
          |> double
          |> allow(:get, fn(%InventoryItem{path: "foo"}) ->
            {:error, "file not found"}
          end)
        end

        it "repopulates the inventory queue" do
          inventory_queue()
          |> Queue.empty?
          |> expect
          |> to_not(be_true())
        end
      end
    end

    context "when the inventory fails to return items" do
      let :mock_inventory do
        DropBox.Inventory
        |> double
        |> allow(:get, fn(%{folder: "foo"}) ->
          {:error, "Something barfed"}
        end)
      end

      it "does not queue anything" do
        inventory_queue()
        |> Queue.empty?
        |> expect
        |> to(be_true())
      end
    end
  end
end
