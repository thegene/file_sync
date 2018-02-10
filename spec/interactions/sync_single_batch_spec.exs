defmodule FileSync.Interactions.SyncSingleBatchSpec do
  use ESpec

  import Double

  alias FileSync.Interactions.{SyncSingleBatch,Source,SyncItem}
  alias FileSync.Boundaries.DropBox
  alias FileSync.Boundaries.FileSystem
  alias FileSync.Data.{InventoryItem,FileData}

  context "Given two sources" do
    let subject: SyncSingleBatch.sync(from: from(), to: to(), opts: opts())

    let from: %Source{ module: drop_box(), opts: from_opts() }
    let to: %Source{}

    let opts: %{logger: logger(), sync_module: sync_module()}

    let :logger, do:
      Logger
      |> double
      |> allow(:error, fn(_) -> nil end)
      |> allow(:info, fn(_) -> nil end)

    let db_response: {:ok, %{items: [%InventoryItem{}]}}
    let from_opts: %{foo: "from"}

    let :drop_box, do:
      %DropBox{
        inventory: db_inventory(),
        file_contents: db_contents()
      }

    let :db_contents, do:
      DropBox.FileContents
      |> double
      |> allow(:get, fn(_inventory_item) -> {:ok, %FileData{}} end)

    context "when we successfully sync from one to the other" do
      before do
        subject()
      end

      let :db_inventory, do:
        DropBox.Inventory
        |> double
        |> allow(:get, fn(_from_opts) -> db_response() end)

      let :sync_module, do:
        SyncItem
        |> double
        |> allow(:sync, fn(_res, _source) -> {:ok, "Successful"} end)

      it "gets the from inventory" do
        assert_received({:get, %{foo: "from"}})
      end

      it "gets an InventoryItem from the from source" do
        assert_received({:get, %InventoryItem{}})
      end

      it "logs the success" do
        assert_received({:info, "Successful"})
      end
    end

    context "when putting a file fails" do
      before do
        subject()
      end

      let :db_inventory, do:
        DropBox.Inventory
        |> double
        |> allow(:get, fn(_from_opts) -> db_response() end)

      let :sync_module, do:
        SyncItem
        |> double
        |> allow(:sync, fn(_res, _source) -> {:error, "some failure"} end)

      it "logs an error" do
        assert_received({:error, "some failure"})
      end
    end

    context "when the inventory cannot get list" do
      before do
        subject()
      end

      let sync_module: SyncItem

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
