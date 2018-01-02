require IEx

opts = %{
  folder: "Harrison Birth",
  limit: 5
}
inventory = FileSync.Boundaries.DropBox.Inventory.get(opts)

IEx.pry
