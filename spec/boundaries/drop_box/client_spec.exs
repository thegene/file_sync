defmodule FileSync.Boundaries.DropBox.ClientSpec do
  use ESpec

  alias FileSync.Boundaries.DropBox.Client

  import Double

  context "Given a DropBox list_folder request" do
    let subject: Client.list_folder(%{folder: "foo", http: mock_http()})

    context "which is successful" do
      let :fixtures_path, do:
        Path.join([
          "spec",
          "fixtures",
          "boundaries",
          "drop_box",
          "list_folder_small.json"
        ])

      let :mock_http, do:
        HTTPoison
        |> double
        |> allow(:post, fn(_url, _body, _headers, _options) ->
          fixtures_path()
          |> File.read!
          |> Poison.decode!
        end)

			it "has 200 status code" do
        {:ok, response} = subject()
        expect(response.status_code).to eq(200)
			end
    end

    xcontext "which returns a drop box error" do
    end

    xcontext "which times out" do
    end
  end
end
