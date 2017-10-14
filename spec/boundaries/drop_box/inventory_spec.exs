defmodule FileSync.Boundaries.DropBox.InventorySpec do
  use ESpec

  alias FileSync.Boundaries.DropBox.Inventory

  import Double

  context "Given a list of files from a dropbox folder" do
    let folder: "foo bar"
    let inventory_opts: %{folder: folder(), http: http()}

    let :subject, do:
      inventory_opts()
      |> Inventory.get

    let :http, do:
      HTTPotion
      |> double
      |> allow(:post, fn(_, _) -> response() end)
    
    let :response, do:
      fixture_path()
      |> File.read!
      |> Poison.decode!(as: %HTTPotion.Response{})

    context "the http request" do
      let :fixture_path, do:
        Path.join([
          "spec",
          "fixtures",
          "boundaries",
          "drop_box",
          "inventory_get.json"
        ])

      it "returns a list of 2000 things" do
        subject()
        |> length
        |> expect
        |> to(eq(2000))
      end
    end
  end
end
