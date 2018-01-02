require IEx

alias FileSync.Boundaries.FileSystem.FileContents
alias FileSync.Data.FileData

path = Path.join(["spec", "fixtures", "harrison_birth.jpg"])
file_content = File.read!(path)

opts = %{
  directory: "data"
}

file = %FileData{content: file_content, name: "harrison_birth.jpg"}

FileContents.put(file, opts)
