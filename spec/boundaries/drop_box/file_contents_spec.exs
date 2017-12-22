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

      let :mock_client, do:
        Client
        |> double
        |> allow(:download, fn(%{path: _path}) ->
          {:ok, %Response{body: response_body()}}
        end)

      it "returns a file contents data object" do
        {:ok, file_data} = subject()
        expect(file_data.content).to eq(response_body())
      end
    end
  end
end
