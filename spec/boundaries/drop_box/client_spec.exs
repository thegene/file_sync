defmodule FileSync.Boundaries.DropBox.ClientSpec do
  use ESpec

  alias FileSync.Boundaries.DropBox.{Client,HttpApi,FolderOptions}

  import Double

  context "Given a DropBox list_folder request" do
    let subject: Client.list_folder(%{folder: "foo", api: mock_api()})

    let :mock_api, do:
      HttpApi
      |> double
      |> allow(:post, fn(
                        endpoint: "list_folder",
                        endpoint_opts: %FolderOptions{folder: "foo"} ) ->
        {:ok, %{
          body: response_body(),
          headers: response_headers(),
          status_code: response_status_code()
        }}
      end)


    context "which is successful" do
      let :fixtures_path, do:
        Path.join([
          "spec",
          "fixtures",
          "boundaries",
          "drop_box",
          "list_folder_small.json"
        ])

      let :response_body, do:
        fixtures_path()
        |> File.read!
        |> Poison.decode!
        |> Map.get("body")

      let :response_headers, do:
        [
          {"Server", "nginx"},
          {"x-dropbox-request-id", "8711e060f291f386b39a3890cbce15b2"},
          {"Other stuff", "blah"}
        ]

      let response_status_code: 200

			it "has 200 status code" do
        {:ok, response} = subject()
        expect(response.status_code).to eq(200)
			end

      it "makes headers available" do
        {:ok, response} = subject()
        response.headers["x-dropbox-request-id"]
        |> expect
        |> to(eq("8711e060f291f386b39a3890cbce15b2"))
      end

      it "has entries in the response body" do
        {:ok, response} = subject()
        response.body
        |> Map.get(:entries)
        |> length
        |> expect
        |> to(eq(21))
      end
    end

    context "which returns a drop box error" do
      let :response_body, do:
        %{
          "error_summary": "path/not_found/.",
          "error": %{
              ".tag": "path",
              "path": %{".tag": "not_found"}
          }
        } |> Poison.encode!

      let :response_headers, do:
        [{"Content-Disposition", "attachment; filename='error'"}]

      let response_status_code: 409

      it "results in an error message" do
        {:error, message} = subject()
        expect(message).to eq("path/not_found/.")
      end
    end

    context "which times out" do
      let :mock_api, do:
        HttpApi
        |> double
        |> allow(:post, fn(_) ->
          {:error, %HTTPoison.Error{id: nil, reason: :connect_timeout}}
        end)

      it "results in an error message" do
        {:error, message} = subject()
        expect(message).to eq("request timed out")
      end
    end
  end
end
