defmodule FileSync.Boundaries.DropBox.ContentHashValidatorSpec do
  use ESpec

  alias FileSync.Data.FileData
  alias FileSync.Boundaries.DropBox.{ContentHashValidator,SourceMeta}
  alias FileSync.Interactions.Source

  let valid_hash: "0f5cd12730cc6dd64a11d5841ee85c3397e61278c9843d1199a0953810223e1f"

  let :file_contents, do:
    [
      "spec",
      "fixtures",
      "harrison_birth.jpg"
    ]
    |> Path.join
    |> File.read!

  let source: %Source{}

  context "Given downloaded FileData" do
    let :file_data, do:
      %FileData{
        content: file_contents(),
        name: "harrison_birth.jpg",
        source_meta: %SourceMeta{content_hash: content_hash()}
      }

    let subject: ContentHashValidator.valid?(file_data(), source())

    context "when the content_hash is valid" do
      let content_hash: valid_hash()

      it "returns the file_data with an :ok" do
        {:ok, data} = subject()
        expect(data).to eq(file_data())
      end
    end

    context "when the content_hash is not valid" do
      let content_hash: "BLAH"

      it "returns :error along with an error message" do
        {:error, message} = subject()
        expect(message).to eq("harrison_birth.jpg failed dropbox content hash comparison")
      end
    end
  end
end
