defmodule FileSync.Boundaries.DropBox.Endpoints.ListFolderSpec do
  use ESpec

  alias FileSync.Boundaries.DropBox.Endpoints.ListFolder

  context "Given a set of options for folder api requests" do
    let endpoint: ListFolder.build_endpoint(%{
      folder: "foo_bar"
    })

    let :expected_payload, do:
      %{
        "path": "/foo_bar",
        "recursive": false,
        "include_media_info": false,
        "include_deleted": false,
        "include_has_explicit_shared_members": false,
        "include_mounted_folders": true
      }
      |> Poison.encode!

    it "gives an encoded json representation including defaults and folder" do
      endpoint()
      |> ListFolder.body
      |> expect
      |> to(eq(expected_payload()))
    end

    it "knows its url" do
      endpoint()
      |> ListFolder.url
      |> to(eq("https://api.dropboxapi.com/2/files/list_folder"))
    end

    it "requests JSON in the headers" do
      endpoint()
      |> ListFolder.headers
      |> expect
      |> to(eq(["Content-Type": "application/json"]))
    end

    it "has a strategy" do
      expect(endpoint().strategy).to eq(ListFolder)
    end
  end
end
