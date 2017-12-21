defmodule FileSync.Boundaries.DropBox.FileDataSpec do
  use ESpec

  alias FileSync.Boundaries.DropBox.FileData

  import Double

  context "Given a request for dropbox file data" do
    let subject: FileData.get_contents(%{path: "foo", client: client()})
    let client: {}

    it "returns a binary file" do
      expect(subject()).to eq("something?")
    end

  end

end
