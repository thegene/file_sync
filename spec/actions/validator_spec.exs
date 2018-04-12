defmodule FileSync.Actions.ValidatorSpec do
  use ESpec

  import Double

  alias FileSync.Actions.Validator
  alias FileSync.Boundaries.DropBox.ContentHashValidator

  context "Given a message to validate" do
    let message: {:ok, %{}}

    let subject: message() |> Validator.validate_with(validator_list())

    let :passing_validator do
      ContentHashValidator
      |> double
      |> allow(:valid?, fn(_message) -> {:ok, %{}} end)
    end

    let :failing_validator do
      ContentHashValidator
      |> double
      |> allow(:valid?, fn(_message) ->
        {:error, "failed for some reason"}
      end)
    end

    context "with an empty validator_list" do
      let validator_list: []

      it "returns the message" do
        subject()
        |> expect
        |> to(eq(message()))
      end
    end

    context "with a single validator" do
      let validator_list: [validator()]

      context "which passes" do
        let validator: passing_validator()

        it "returns the message" do
          subject()
          |> expect
          |> to(eq(message()))
        end
      end

      context "which fails" do
        let validator: failing_validator()

        it "returns a failure message with reason" do
          {:error, message} = subject()
          message
          |> expect
          |> to(eq("failed for some reason"))
        end
      end
    end

    context "with two conflicting validators" do
      let validator_list: [passing_validator(), failing_validator()]

      it "returns a failure message with reason" do
        {:error, message} = subject()
        message
        |> expect
        |> to(eq("failed for some reason"))
      end
    end
  end
end
