defmodule FileSync.Interactions.SyncServerSpec do
  use ESpec
  require IEx

  alias FileSync.Interactions.SyncServer
  alias FileSync.Interactions.Source
  alias FileSync.Actions.Queue
  alias FileSync.Boundaries.{DropBox, FileSystem}
  alias FileSync.Data.{InventoryItem, FileData}

  import Double

  context "Given a source and a target source" do
    before do
      SyncServer.sync(source: source(), target: target())
    end

    let source: %Source{
      inventory: mock_inventory(),
      opts: source_opts(),
      contents: mock_db_contents(),
      queue_name: :source_queue
    }

    let target: %Source{
      queue_name: :target_queue,
      contents: mock_fs_contents(),
      opts: target_opts()
    }

    let source_opts: %{
      folder: "foo"
    }

    let target_opts: %FileSystem.Options{
      directory: "bar"
    }

    let mock_db_contents: %{}
    let mock_fs_contents: %{}


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
          {:ok, [%InventoryItem{path: "foo"}]}
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

        it "sends the file contents to the target source" do
          assert_received({
            :put,
            %FileData{},
            %FileSystem.Options{}
          })
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
