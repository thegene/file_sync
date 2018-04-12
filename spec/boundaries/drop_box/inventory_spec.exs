defmodule FileSync.Boundaries.DropBox.InventorySpec do
  use ESpec

  alias FileSync.Boundaries.DropBox.{Inventory, Client}
  alias FileSync.Data.{InventoryFolder, InventoryItem}

  import Double

  context "Given a dropbox client" do
    let :client, do:
      Client
      |> double
      |> allow(:list_folder, fn(%{folder: requested_folder}) ->
        handle_folder(requested_folder)
      end)

    context "when we request a folder's contents" do
      let subject: Inventory.get(%{folder: folder(), client: client()})

      context "and the request is successful" do
        let folder: "foo"
        let :folder_contents, do:
          [%{
            ".tag" => "file",
            "client_modified" => "2016-03-24T03:16:27Z",
            "content_hash" => "3d0856b16890dcfcaba659bc62f51530ca56277e3710f3dba618ce1cb10ca294",
            "id" => "id:YWZvn7UeTVAAAAAAAAAQDQ",
            "name" => "IMG_0278.jpg",
            "path_display" => "/harrison birth/IMG_0278.jpg",
            "path_lower" => "/harrison birth/img_0278.jpg",
            "rev" => "20f637cc1c83",
            "server_modified" => "2016-03-24T03:16:27Z",
            "size" => 8744156
          }, %{
            ".tag" => "folder",
            "id" => "id:XrjEav4csTAAAAAAAAAAAQ",
            "name" => "thumbs",
            "path_display" => "/harrison birth/thumbs",
            "path_lower" => "/harrison birth/thumbs"
          }]
        def handle_folder("foo") do
          {:ok, %{body: %{:entries => folder_contents()}}}
        end

        it "parses the resulting folder contents into inventory items" do
          {:ok, list} = subject()
          list
          |> Enum.filter(fn(item) -> match?(%InventoryItem{}, item) end)
          |> length
          |> expect
          |> to(eq(1))
        end

        it "also parses the resulting folder contents into inventory folders" do
          {:ok, list} = subject()
          list
          |> Enum.filter(fn(item) -> match?(%InventoryFolder{}, item) end)
          |> length
          |> expect
          |> to(eq(1))
        end
      end

      context "and the request is unsuccessful" do
        let folder: "bar"

        def handle_folder("bar") do
          {:error, "something borked"}
        end

        it "passes the response message from the client" do
          {:error, reason} = subject()
          reason
          |> expect
          |> to(eq("something borked"))
        end
      end

    end
  end
end
