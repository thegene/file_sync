require IEx

alias FileSync.Boundaries.DropBox.Client

cursor =
  Path.join([
    "spec",
    "fixtures",
    "boundaries",
    "drop_box",
    "list_folder_small.json"
  ])
  |> File.read!
  |> Poison.decode!
  |> Map.get("body")
  |> Poison.decode!
  |> Map.get("cursor")

{:ok, res} = Client.list_folder_continue(%{cursor: cursor})

IEx.pry
