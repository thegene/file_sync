defmodule FileSync.Boundaries.DropBox.Options do
  defstruct [
    :strategy_opts, # The options to pass to the strategy
    :token, # The dropbox token to use for authentication
    :token_file_path # A path to file in which the can be found a token
  ]
end
