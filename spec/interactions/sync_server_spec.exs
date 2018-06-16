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
      SyncServer.sync(source: source(), queue: queue())
    end

    let source: %Source{
      inventory: mock_inventory(),
      opts: source_opts(),
      contents: mock_file_contents()
    }

    let queue: Queue.start_link() |> elem(1)

    let target: %Source{}

    let source_opts: %{
      folder: "foo"
    }

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

        it "populates a queue for now" do
          queue()
          |> Queue.empty?
          |> expect
          |> not_to(be_true())
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

        it "populates a queue for now" do
          queue()
          |> Queue.empty?
          |> expect
          |> to(be_true())
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
        queue()
        |> Queue.empty?
        |> expect
        |> to(be_true())
      end
    end
  end
end
