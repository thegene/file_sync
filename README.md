# FileSync

Tool which syncs files across cloud and local storage locations.

- DropBox
- Google Cloud
- AWS S3
- Local Storage

WIP: so far only supports DropBox > Local syncing.

## Running example
You will need to create two `Source`es, the first being the file source and the
latter being the target source. In this example, we're copying files from a
DropBox folder `My Pictures` and saving them in a local directory `/drop_box_files`

NOTE: I haven't set up an actual application yet for this, so it's still
hilariously manual.

```elixir
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
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `file_sync` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:file_sync, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/file_sync](https://hexdocs.pm/file_sync).

