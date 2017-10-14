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
    
    context "the http request" do
      let response: %{body: Poison.encode!(%{entries: "foo"})}

      it "calls HTTPotion according to DropBox's API" do
        expect(subject())
        |>to(eq("foo"))
      end
    end
  end
end
