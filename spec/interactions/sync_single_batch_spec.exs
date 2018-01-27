defmodule FileSync.Interactions.SyncSingleBatchSpec do
  use ESpec

  import Double

  alias FileSync.Interactions.SyncSingleBatch
  alias FileSync.Boundaries.DropBox
  alias FileSync.Boundaries.FileSystem
  alias FileSync.Data.InventoryItem

  context "Given we are syncing an inventory from one inventory to another" do
    let subject: SyncSingleBatch.sync(opts())
    let opts: %{
      from: drop_box(),
      from_opts: from_opts(),
      to_opts: to_opts(),
      to: fs()
    }

    let inventory_item: %InventoryItem{}
    let db_response: {:ok, %{items: [inventory_item()]}}
    let from_opts: %{}
    let to_opts: %{}

    let :drop_box, do:
      DropBox
      |> double
      |> allow(:inventory, fn() -> db_inventory() end)
      |> allow(:file_contents, fn() -> db_contents() end)

    let :db_inventory, do:
      DropBox.Inventory
      |> double
      |> allow(:get, fn(_from_opts) -> db_response() end)

    let :db_contents, do:
      DropBox.FileContents
      |> double
      |> allow(:get, fn(_inventory_item) -> {:ok, %{}} end)

    let :fs_file_contents, do:
      FileSystem.FileContents
      |> double
      |> allow(:put, fn(_item, _to_opts) -> end)

    let! :fs, do:
      FileSystem
      |> double
      |> allow(:file_contents, fn() -> fs_file_contents() end)

    it "calls #get on the from source" do
      subject()
    end
  end
end
