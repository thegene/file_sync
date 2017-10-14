defmodule FileSync.Boundaries.DropBox.InventorySpec do
  use ESpec

  alias FileSync.Boundaries.DropBox.Inventory

  import Double

  context "Given a list of files exists in dropbox" do
    let :foo_fixture_path, do:
      Path.join([
        "spec",
        "fixtures",
        "boundaries",
        "drop_box",
        "inventory_get_foo.json"
      ])

    let :bar_fixture_path, do:
      Path.join([
        "spec",
        "fixtures",
        "boundaries",
        "drop_box",
        "inventory_get_bar.json"
      ])

    let inventory_opts: %{folder: folder(), http: http()}

    let :subject, do:
      inventory_opts()
      |> Inventory.get

    let :http, do:
      HTTPotion
      |> double
      |> allow(:post, fn(_url, post_opts) ->
          path = Keyword.fetch!(post_opts, :body)
                 |> Poison.decode!
                 |> Map.get("path")

          case path do
            "/foo" -> foo_response()
            "/bar" -> bar_response()
          end
        end)
    
    let :bar_response, do:
      bar_fixture_path()
      |> File.read!
      |> Poison.decode!(as: %HTTPotion.Response{})

    let :foo_response, do:
      foo_fixture_path()
      |> File.read!
      |> Poison.decode!(as: %HTTPotion.Response{})

    context "when we specify a folder with at least 2000 items" do
      let folder: "foo"

      it "returns a list of 2000 things" do
        subject()
        |> Map.get(:items)
        |> length
        |> expect
        |> to(eq(2000))
      end

      xit "returns InventoryListItems" do
      end
    end

    context "when we specify a folder with only 21 items" do
      let folder: "bar"

      it "returns a list of 21 things" do
        subject()
        |> Map.get(:items)
        |> length
        |> expect
        |> to(eq(21))
      end
    end
  end
end
