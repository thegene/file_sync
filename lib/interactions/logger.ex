defmodule FileSync.Interactions.Logger do
  require Logger

  def warn(message) do
    Logger.warn fn -> message end
  end

  def error(message) do
    Logger.error fn -> message end
  end
end
