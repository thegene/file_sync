defmodule FileSync.Interactions.SyncSingleBatchSpec do
  use ESpec

  import Double

  alias FileSync.Interactions.SyncSingleBatch
  alias FileSync.Interactions.Source
  alias FileSync.Boundaries.DropBox
  alias FileSync.Boundaries.FileSystem
  alias FileSync.Data.{InventoryItem,FileData}

  context "Given two sources" do
    let subject: SyncSingleBatch.sync(from: from(), to: to(), opts: opts())

    let from: %Source{ module: drop_box(), opts: from_opts() }
    let to: %Source{ module: fs(), opts: to_opts() }
    let opts: %{logger: logger()}

    let :logger, do:
      Logger
      |> double
      |> allow(:error, fn(_) -> nil end)

    let db_response: {:ok, %{items: [%InventoryItem{}]}}
    let from_opts: %{foo: "from"}
    let to_opts: %{foo: "to opts"}

    let :drop_box, do:
      %DropBox{
        inventory: db_inventory(),
        file_contents: db_contents()
      }

    let :db_contents, do:
      DropBox.FileContents
      |> double
      |> allow(:get, fn(_inventory_item) -> {:ok, %FileData{}} end)

    let :fs, do:
      %FileSystem{
        file_contents: fs_file_contents()
      }

    context "when we successfully sync from one to the other" do
      before do
        subject()
      end

      let :fs_file_contents, do:
        FileSystem.FileContents
        |> double
        |> allow(:put, fn(_item, _to_opts) -> nil end)

      let :db_inventory, do:
        DropBox.Inventory
        |> double
        |> allow(:get, fn(_from_opts) -> db_response() end)

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

    context "when putting a file fails" do
      before do
        subject()
      end

      let :fs_file_contents, do:
        FileSystem.FileContents
        |> double
        |> allow(:put, fn(_item, _to_opts) -> {:error, "some failure"} end)

      let :db_inventory, do:
        DropBox.Inventory
        |> double
        |> allow(:get, fn(_from_opts) -> db_response() end)

      it "logs an error" do
        assert_received({:error, "Could not put file data: some failure"})
      end
    end

    context "when the inventory cannot get list" do
      before do
        subject()
      end

      let :db_inventory, do:
        DropBox.Inventory
        |> double
        |> allow(:get, fn(_from_opts) -> {:error, "Inventory error"} end)

      let :fs_file_contents, do:
        FileSystem.FileContents
        |> double
        |> allow(:put, fn(_item, _to_opts) -> {:error, "some failure"} end)

      it "logs an error" do
        assert_received({:error, "Failed to get inventory: Inventory error"})
      end

    end
  end
end
