require IEx

alias FileSync.Interactions.SyncServer

alias FileSync.Boundaries.{
  FileSystem,
  DropBox
}

# DropBox options:
folder = "Harrison Birth" # The name of the folder you want to sync. Doesn't do nested folders yet
limit = 3 # The page size for querying. Re-queries every hour
token_file_path = "tmp/dropbox_token" # path to a file containing your dropbox api token

# FileSystem options:
target_directory = "data" # Directory where you want to save your files


source = DropBox.default_source(folder, limit, token_file_path)

target = FileSystem.default_target(target_directory)

{:ok, server} = SyncServer.start_link(source: source, target: target)

IEx.pry
