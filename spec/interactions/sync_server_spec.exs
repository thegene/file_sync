defmodule FileSync.Interactions.SyncServerSpec do
  use ESpec
  require IEx

  alias FileSync.Interactions.SyncServer
  alias FileSync.Interactions.Source
  alias FileSync.Actions.Queue
  alias FileSync.Boundaries.DropBox
  alias FileSync.Data.{InventoryItem, FileData}

  import Double

  context "Given a source and a target source" do
    before do
      SyncServer.sync(source: source(), target: target())
    end

    let source: %Source{
      inventory: mock_inventory(),
      opts: source_opts(),
      contents: mock_file_contents(),
      queue_name: :source_queue
    }

    let target: %Source{queue_name: :target_queue}

    let source_opts: %{
      folder: "foo"
    }

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
        let :mock_file_contents do
          DropBox.FileContents
          |> double
          |> allow(:get, fn(%InventoryItem{path: "foo"}) ->
            {:ok, %FileData{}}
          end)
        end

        it "populates the content queue" do
          content_queue()
          |> Queue.empty?
          |> expect
          |> to_not(be_true())
        end
      end

      context "and file contents fails to get file data" do
        let :mock_file_contents do
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
      let mock_file_contents: %{}

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
