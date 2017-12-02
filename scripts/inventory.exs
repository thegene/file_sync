require IEx

opts = %{folder: "Harrison Birth"}
inventory = FileSync.Boundaries.DropBox.Inventory.get(opts)

IEx.pry
