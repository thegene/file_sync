defmodule FileSync.Boundaries.DropBox.FileContentsSpec do
  use ESpec
  require IEx

  alias FileSync.Boundaries.DropBox.{
    FileContents,
    Client,
    Response,
    ResponseParsers,
    Endpoints,
    Options
  }
  alias FileSync.Data.InventoryItem

  import Double

  context "Given a request for file contents of an InventoryItem" do
    let item: %InventoryItem{path: "foo.txt"}
    let subject: FileContents.get(item(), opts(), mock_client())
    let opts: %Options{token: "bar"}

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
        |> allow(:request, fn(
                   %{token: "bar", path: "foo.txt"},
                   Endpoints.Download,
                   ResponseParsers.Download) ->
          {:ok, %Response{body: response_body(), headers: response_headers()}}
        end)

      before do
        {:ok, file_data} = subject()
        {:shared, %{file_data: file_data}}
      end

      it "returns a file contents data object" do
        expect(shared.file_data.content).to eq(response_body())
      end

      it "returns a file with the name supplied in the headers" do
        expect(shared.file_data.name).to eq("IMG_0305.jpg")
      end

      it "sets the size of the file" do
        expect(shared.file_data.size).to eq(8970555)
      end

      it "sets content hash into the filedata source_meta" do
        expect(shared.file_data.source_meta.content_hash).to eq("BLAH")
      end
    end

    context "when it fails" do
      let :mock_client, do:
        Client
        |> double
        |> allow(:request, fn(_, _, _) -> {:error, "Some error message"} end)

      it "passes the error state along" do
        {:error, message} = subject()
        expect(message).to eq("Some error message")
      end
    end
  end
end
