defmodule FileSync.Boundaries.DropBox.Endpoints.ListFolderContinueSpec do
  use ESpec

  alias FileSync.Boundaries.DropBox.Endpoints.ListFolderContinue

  context "Given a cursor" do
    let endpoint: ListFolderContinue.build_endpoint(%{cursor: "foo"})

    let :body do
      endpoint()
      |> ListFolderContinue.body
      |> Poison.decode!
    end

    it "builds headers" do
      endpoint()
      |> ListFolderContinue.headers
      |> expect
      |> to(eq(["Content-Type": "application/json"]))
    end

    it "knows its url" do
      endpoint()
      |> ListFolderContinue.url
      |> to(eq("https://api.dropboxapi.com/2/files/list_folder/continue"))
    end

    it "includes the cursor in the request body" do
      body()
      |> expect
      |> to(eq(%{"cursor" => "foo"}))
    end
  end
end
