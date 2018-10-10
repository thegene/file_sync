defmodule FileSync.Boundaries.DropBox.ClientSpec do
  use ESpec

  alias FileSync.Boundaries.DropBox.{
    Client,
    HttpApi,
    Response,
    Endpoints,
    ResponseParsers
  }

  import Double

  context "Given a DropBox Client with an http_api" do
    let :mock_api, do:
      HttpApi
      |> double
      |> allow(:post, fn(%{endpoint: _, token: "whoabar"}) ->
        {:ok, %{
          body: response_body(),
          headers: [],
          status_code: response_status_code()
        }}
      end)
    
    context "when we make a request with an Endpoint and Parser" do
      let subject: Client.request(opts(), endpoint(), parser())

      let :opts do
        %{
          folder: "foo",
          api: mock_api(),
          token: "whoabar"
        }
      end

      let endpoint: Endpoints.ListFolder

      let :parser do
        ResponseParsers.ListFolder
        |> double
        |> allow(:parse, fn(_response) ->
          %Response{
            status_code: 200,
            headers: %{},
            body: "moar stuff"
          }
        end)
      end

      context "which is successful" do
        let response_status_code: 200
        let response_body: "stuff" |> Poison.encode!

        it "passes the endpoint and token to the http_api" do
          subject()
          assert_received({:post, %{
                            endpoint: %Endpoints.ListFolder{folder: "foo"},
                            token: "whoabar"
          }})
        end

        it "uses the parser to parse the response body" do
          subject()
          assert_received({:parse, %{
                            body: "\"stuff\""
                          }})
        end
      end

      context "which is not successful" do
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

        it "returns the detailed response body" do
          {:error, res} = subject()
          res
          |> expect
          |> to(eq("path/not_found/."))
        end
      end

      context "which experiences connection error" do
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

      context "which responds with a 400" do
        let :response_body do
          "Error in call to API function " <>
          "\"files/list_folder/continue\": Invalid \"cursor\" parameter: 'foo'"
        end

        let response_status_code: 400

        let :response_headers, do:
          [{"Content-Disposition", "attachment; filename='error'"}]

        it "results in an error message" do
          {:error, message} = subject()
          message
          |> expect
          |> to(eq(
            "Error in call to API function " <>
            "\"files/list_folder/continue\": " <>
            "Invalid \"cursor\" parameter: 'foo'"
          ))
        end
      end
    end
  end
end
