require IEx

alias FileSync.Boundaries.DropBox.FileContents
alias FileSync.Data.InventoryItem

path =  "/harrison birth/img_0305.jpg"

file_data = FileContents.get(%InventoryItem{path: path})

IEx.pry
