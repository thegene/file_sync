defmodule FileSync.Boundaries.DropBox.HttpApiSpec do
  use ESpec

  alias FileSync.Boundaries.DropBox.{HttpApi,FolderOptions}

  import Double
  require IEx

  context "Given a post to the DropBox HTTP Api" do
    let :mock_http, do:
      HTTPoison
      |> double
      |> allow(:post, fn(_url, _body, _headers, _options) ->
        {:ok, "whatever"}
      end)

    context "when we post to the list_folder endpoint" do
      let subject: HttpApi.post(opts())

      let opts: %{
        endpoint: "list_folder",
        endpoint_opts: "SOME ENCODED FOLDER OPTIONS",
        http: mock_http()
      }

      it "makes a post to the requested endpoint url" do
        subject()
        assert_received({
                          :post,
                          "https://api.dropboxapi.com/2/files/list_folder",
                          _,_,_
                        })
      end

      it "requests default folder options and specified path" do
        subject()

        assert_received({
                          :post,
                          _,
                          "SOME ENCODED FOLDER OPTIONS",
                          _,
                          _
                        })
      end

    end
  end
end
