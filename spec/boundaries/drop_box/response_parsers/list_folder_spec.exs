defmodule FileSync.Boundaries.DropBox.ResponseParsers.ListFolderSpec do
  use ESpec

  alias FileSync.Boundaries.DropBox.ResponseParsers.ListFolder
  require IEx

  context "Given a successful response with a body" do
    let(:response_data) do
      [
        "spec",
        "fixtures",
        "boundaries",
        "drop_box",
        "list_folder_small.json"
      ]
      |> Path.join
      |> File.read!
      |> Poison.decode!
    end

    let(:response) do
      %{
        status_code: response_data()["status_code"],
        headers: [],
        body: response_data()["body"]
      }
    end

    let parsed_response: response() |> ListFolder.parse
    let parsed_body: parsed_response().body

    context "when we look at the entries" do
      let entries: parsed_body()[:entries]

      let(:items) do
        entries()
        |> Enum.filter(fn(entry) -> entry |> Map.has_key?(:size) end)
      end

      let(:folders) do
        entries()
        |> Enum.filter(fn(entry) -> entry |> Map.has_key?(:size) != true end)
      end

      it "returns a bunch of items" do
        items()
        |> length
        |> expect
        |> to(eq(20))
      end

      it "returns one folder" do
        folders()
        |> length
        |> expect
        |> to(eq(1))
      end
    end
  end
end
