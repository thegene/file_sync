defmodule FileSync.Boundaries.DropBox.FileContentsSpec do
  use ESpec

  alias FileSync.Boundaries.DropBox.{FileContents,Client,Response}

  import Double

  context "Given a request for file contents of a path" do
    let subject: FileContents.get(%{path: "foo.txt", client: mock_client()})

    context "when successful" do
      let :response_body, do:
        [
          "spec",
          "fixtures",
          "harrison_birth.jpg"
        ]
        |> Path.join
        |> File.read!

      let :response_headers, do:
         %{
           "file_data" => %{
             "name" => "IMG_0305.jpg",
             "path_lower" => "harrison birthimg_0305.jpg",
             "path_display" => "harrison birthIMG_0305.jpg",
             "id" => "id:_VGSApTbVDAAAAAAAAAAAQ",
             "client_modified" => "2016-03-24T03:28:19Z",
             "server_modified" => "2016-03-24T03:28:19Z",
             "rev" => "20fe37cc1c83",
             "size" => 8970555,
             "content_hash" => "BLAH"
           }
          }

      let :mock_client, do:
        Client
        |> double
        |> allow(:download, fn(%{path: _path}) ->
          {:ok, %Response{body: response_body(), headers: response_headers()}}
        end)

      it "returns a file contents data object" do
        h = response_headers()
        {:ok, file_data} = subject()
        expect(file_data.content).to eq(response_body())
      end

      it "returns a file with the name supplied in the headers" do
        {:ok, file_data} = subject()
        expect(file_data.name).to eq("IMG_0305.jpg")
      end

    end

    context "when it fails" do
      let :mock_client, do:
        Client
        |> double
        |> allow(:download, fn(_) -> {:error, "Some error message"} end)

      it "passes the error state along" do
        {:error, message} = subject()
        expect(message).to eq("Some error message")
      end
    end
  end
end
