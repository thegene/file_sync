defmodule FileSync.Boundaries.DropBox.Endpoints.ListFolderSpec do
  use ESpec

  alias FileSync.Boundaries.DropBox.Endpoints.ListFolder

  context "Given a set of options for folder api requests" do
    let endpoint: ListFolder.build_endpoint(params())

    let :expected_payload, do:
      expected() |> Poison.encode!

    context "out of the box" do
      let params: %{folder: "foo_bar"}

      let :expected, do:
        %{
          "path": "/foo_bar",
          "recursive": false,
          "include_media_info": false,
          "include_deleted": false,
          "include_has_explicit_shared_members": false,
          "include_mounted_folders": true
        }

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

    context "when passed optional params" do

      let :params do
        required_params()
        |> Map.merge(optional_params())
      end

      let required_params: %{folder: "foo_bar"}

      context "including limit" do
        let optional_params: %{limit: 5}

        it "includes limit in the body json" do
          endpoint()
          |> ListFolder.body
          |> Poison.decode!
          |> Map.get("limit")
          |> expect
          |> to(eq(5))
        end
      end

      context "including cursor" do
        let optional_params: %{cursor: "ABCdefg"}

        it "includes only cursor in the body json" do
          endpoint()
          |> ListFolder.body
          |> Poison.decode!
          |> expect
          |> to(eq(%{"cursor" => "ABCdefg"}))
        end

        it "changes the url to continue" do
          endpoint()
          |> ListFolder.url
          |> expect
          |> to(eq("https://api.dropboxapi.com/2/files/list_folder/continue"))
        end
      end
    end
  end
end
