require IEx

alias FileSync.Boundaries.DropBox.FileContents

path =  "/harrison birth/img_0305.jpg"

file_data = FileContents.get(%{path: path})

IEx.pry
