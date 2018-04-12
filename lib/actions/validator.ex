defmodule FileSync.Actions.Validator do
  def validate_with(message, validator_list) do
    message
    |> validate(validator_list)
  end

  defp validate(message = {:ok, _data}, []) do
    message
  end

  defp validate(message = {:ok, data}, validators) do
    [validator | rest] = validators

    data
    |> validator.valid?
    |> validate(rest)
  end

  defp validate(res = {:error, message}, _validators) do
    res
  end
end
