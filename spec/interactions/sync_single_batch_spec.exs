defmodule FileSync.Interactions.SyncSingleBatchSpec do
  use ESpec

  import Double

  alias FileSync.Interactions.SyncSingleBatch
  alias FileSync.Interactions.Source
  alias FileSync.Boundaries.DropBox
  alias FileSync.Boundaries.FileSystem
  alias FileSync.Data.{InventoryItem,FileData}

  context "Given two sources" do
    let subject: SyncSingleBatch.sync(from: from(), to: to())

    let from: %Source{ module: drop_box(), opts: from_opts() }
    let to: %Source{ module: fs(), opts: to_opts() }

    let db_response: {:ok, %{items: [%InventoryItem{}]}}
    let from_opts: %{foo: "from"}
    let to_opts: %{foo: "to opts"}

    let :drop_box, do:
      %DropBox{
        inventory: db_inventory(),
        file_contents: db_contents()
      }

    let :db_inventory, do:
      DropBox.Inventory
      |> double
      |> allow(:get, fn(_from_opts) -> db_response() end)

    let :db_contents, do:
      DropBox.FileContents
      |> double
      |> allow(:get, fn(_inventory_item) -> {:ok, %FileData{}} end)

    let :fs, do:
      %FileSystem{
        file_contents: fs_file_contents()
      }

    let :fs_file_contents, do:
      FileSystem.FileContents
      |> double
      |> allow(:put, fn(_item, _to_opts) -> end)

    context "when we sync from one to the other" do
      before do
        subject()
      end

      it "gets the from inventory" do
        assert_received({:get, %{foo: "from"}})
      end

      it "gets an InventoryItem from the from source" do
        assert_received({:get, %InventoryItem{}})
      end

      it "puts the FileData into the to file contents" do
        assert_received({:put, %FileData{}, %{foo: "to opts"}})
      end
    end
  end
end
