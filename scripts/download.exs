require IEx

alias FileSync.Boundaries.DropBox.FileContents
alias FileSync.Boundaries.DropBox.Endpoints.Download

path =  "/harrison birth/img_0305.jpg"

file_data = FileContents.get(%{path: path})

IEx.pry
