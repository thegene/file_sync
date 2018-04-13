defmodule FileSync.Actions.Validator do

  alias FileSync.Interactions.Source

  def validate_with(message, source = %Source{}) do
    message
    |> validate(source.validators, source)
  end

  defp validate(message = {:ok, _data}, [], _source = %Source{}) do
    message
  end

  defp validate({:ok, data}, validators, source = %Source{}) do
    [validator | rest] = validators

    data
    |> validator.valid?(source)
    |> validate(rest, source)
  end

  defp validate(res = {:error, _message}, _validators, _source) do
    res
  end
end
