defmodule FileSync.Boundaries.DropBox.ClientSpec do
  use ESpec

  alias FileSync.Boundaries.DropBox.{Client,HttpApi,Response}

  import Double

  context "Given a DropBox Client" do
    let :mock_api, do:
      HttpApi
      |> double
      |> allow(:post, fn(%{endpoint: _}) ->
        {:ok, %{
          body: response_body(),
          headers: response_headers(),
          status_code: response_status_code()
        }}
      end)

    context "when we make a list_folder request" do
      let subject: Client.list_folder(%{folder: "foo", api: mock_api()})

      context "which is successful" do
        let :fixtures_path, do:
          Path.join([
            "spec",
            "fixtures",
            "boundaries",
            "drop_box",
            "list_folder_small.json"
          ])

        let :response_body, do:
          fixtures_path()
          |> File.read!
          |> Poison.decode!
          |> Map.get("body")

        let :response_headers, do:
          [
            {"Server", "nginx"},
            {"x-dropbox-request-id", "8711e060f291f386b39a3890cbce15b2"},
            {"Other stuff", "blah"}
          ]

        let response_status_code: 200

        it "has 200 status code" do
          {:ok, response} = subject()
          expect(response.status_code).to eq(200)
        end

        it "makes headers available" do
          {:ok, response} = subject()
          response.headers["x-dropbox-request-id"]
          |> expect
          |> to(eq("8711e060f291f386b39a3890cbce15b2"))
        end

        it "has entries in the response body" do
          {:ok, response} = subject()
          response.body
          |> Map.get(:entries)
          |> length
          |> expect
          |> to(eq(21))
        end
      end

      context "which returns a drop box error" do
        let :response_body, do:
          %{
            "error_summary": "path/not_found/.",
            "error": %{
                ".tag": "path",
                "path": %{".tag": "not_found"}
            }
          } |> Poison.encode!

        let :response_headers, do:
          [{"Content-Disposition", "attachment; filename='error'"}]

        let response_status_code: 409

        it "results in an error message" do
          {:error, message} = subject()
          expect(message).to eq("path/not_found/.")
        end
      end

      context "which times out" do
        let :mock_api, do:
          HttpApi
          |> double
          |> allow(:post, fn(_) ->
            {:error, %HTTPoison.Error{id: nil, reason: :connect_timeout}}
          end)

        it "results in an error message" do
          {:error, message} = subject()
          expect(message).to eq("request timed out")
        end
      end
    end

    context "when we make a download request" do
      let subject: Client.download(%{path: "foo_bar", api: mock_api()})

      context "which is successful" do
        let :response_body, do:
          [
            "spec",
            "fixtures",
            "harrison_birth.jpg"
          ]
          |> Path.join
          |> File.read!

        let :response_headers, do:
          [
            {"Server", "nginx"},
            {"Content-Type", "application/octet-stream"},
            {"Content-Length", "8970555"},
            {"original-content-length", "8970555"},
            {"dropbox-api-result",
             "{\"name\": \"IMG_0305.jpg\", \"path_lower\": \"/harrison birth/img_0305.jpg\", \"path_display\": \"/harrison birth/IMG_0305.jpg\", \"id\": \"id:_VGSApTbVDAAAAAAAAAAAQ\", \"client_modified\": \"2016-03-24T03:28:19Z\", \"server_modified\": \"2016-03-24T03:28:19Z\", \"rev\": \"20fe37cc1c83\", \"size\": 8970555, \"media_info\": {\".tag\": \"metadata\", \"metadata\": {\".tag\": \"photo\", \"dimensions\": {\"height\": 7200, \"width\": 4800}, \"time_taken\": \"2016-03-16T11:25:48Z\"}}, \"content_hash\": \"0f5cd12730cc6dd64a11d5841ee85c3397e61278c9843d1199a0953810223e1f\"}"},
            {"X-Dropbox-Request-Id", "cc3769f60a27887c962cb5a8a2420f3f"},
            {"X-Robots-Tag", "noindex, nofollow, noimageindex"}
          ]

        let response_status_code: 200

        it "returns a Response with binary content" do
          {:ok, %Response{body: content}} = subject()
          expect(content).to eq(response_body())
        end

        it "makes available the fiel name in the headers" do
          {:ok, %Response{headers: headers}} = subject()
          expect(headers["file_data"]["name"]).to eq("IMG_0305.jpg")
        end
      end

      context "which fails" do
        let :response_body, do:
          %{
            "error_summary": "path/not_found/.",
            "error": %{
                ".tag": "path",
                "path": %{".tag": "not_found"}
            }
          } |> Poison.encode!

        let :response_headers, do:
          [{"Content-Disposition", "attachment; filename='error'"}]

        let response_status_code: 409

        it "results in an error message" do
          {:error, message} = subject()
          expect(message).to eq("path/not_found/.")
        end
      end

      context "which times out" do
        let :mock_api, do:
          HttpApi
          |> double
          |> allow(:post, fn(_) ->
            {:error, %HTTPoison.Error{id: nil, reason: :connect_timeout}}
          end)

        it "results in an error message" do
          {:error, message} = subject()
          expect(message).to eq("request timed out")
        end
      end
    end
  end
end
