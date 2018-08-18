defmodule FileSync.Interactions.Logger do
  require Logger

  def warn(message) do
    Logger.warn(message)
  end

  def error(message) do
    Logger.error(message)
  end

  def info(message) do
    Logger.info(message)
  end
end
