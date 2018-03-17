defmodule FileSync.Boundaries.DropBox.FileContentsSpec do
  use ESpec
  require IEx

  alias FileSync.Boundaries.DropBox.{FileContents,Client,Response,ContentHashValidator}
  alias FileSync.Data.InventoryItem

  import Double

  context "Given a request for file contents of an InventoryItem" do
    let item: %InventoryItem{path: "foo.txt"}
    let subject: FileContents.get(item(), dependencies())
    let dependencies: %{client: mock_client(), validators: [mock_validator()]}

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

      context "and the validations pass" do
        let :mock_validator, do:
          ContentHashValidator
          |> double
          |> allow(:valid?, fn(item) -> {:ok, item} end)

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

        it "sets content hash into the fildata source_meta" do
          expect(shared.file_data.source_meta.content_hash).to eq("BLAH")
        end
      end

      context "and the validations fail" do
        let :mock_validator, do:
          ContentHashValidator
          |> double
          |> allow(:valid?, fn(_item) -> {:error, "something's bad"} end)

        it "passes along the error" do
          {:error, message} = subject()
          expect(message).to eq("something's bad")
        end
      end
    end

    context "when it fails" do
      let :mock_client, do:
        Client
        |> double
        |> allow(:download, fn(_) -> {:error, "Some error message"} end)

      let :mock_validator, do:
        ContentHashValidator
        |> double
        |> allow(:valid?, fn(item) -> {:ok, item} end)

      it "passes the error state along" do
        {:error, message} = subject()
        expect(message).to eq("Some error message")
      end
    end
  end
end
