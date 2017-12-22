defmodule FileSync.Boundaries.DropBox.HttpApiSpec do
  use ESpec

  alias FileSync.Boundaries.DropBox.Endpoints.{ListFolder,Download}
  alias FileSync.Boundaries.DropBox.HttpApi

  import Double
  require IEx

  context "Given a post to the DropBox HTTP Api" do
    let subject: HttpApi.post(opts())

    let :mock_http, do:
      HTTPoison
      |> double
      |> allow(:post, fn(_url, _body, _headers, _options) ->
        {:ok, "whatever"}
      end)

    context "when we post to the list_folder endpoint" do
      let opts: %{
        endpoint: "list_folder",
        endpoint_opts: %ListFolder{folder: "foo"},
        token: "overridden token",
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
                          "{\"recursive\":false,\"path\":\"/foo\",\"include_mounted_folders\":true,\"include_media_info\":false,\"include_has_explicit_shared_members\":false,\"include_deleted\":false}",
                          _,
                          _
                        })
      end

      it "sends content type and auth headers" do
        subject()

        assert_received({
                          :post,
                          _,
                          _,
                          [
                            "Authorization": "Bearer overridden token",
                            "Content-Type": "application/json"
                          ],
                          _
                        })

      end

      it "sends with default http options" do
        subject()

        assert_received({
                          :post,
                          _,
                          _,
                          _,
                          [timeout: 8000]
                        })
      end
    end

    context "when we post to the download endpoint" do
      let opts: %{
        endpoint: "download",
        endpoint_opts: %Download{ path: "foo.txt" },
        token: "overridden token",
        http: mock_http()
      }

      it "posts to the download endpoint requesting the specified file path" do
        subject()

        assert_received({
                          :post,
                          "https://content.dropboxapi.com/2/files/download",
                          "{\"path\":\"foo.txt\"}",
                          _,
                          _
                        })
      end

    end
  end
end
