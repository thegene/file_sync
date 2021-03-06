defmodule FileSync.Interactions.Source do
  #module is deprecated, will remove
  defstruct [
    :module, # only used in sync_item, remove
    :inventory, # module to use to list the inventory of a source
    :contents, # module to use for fetching and saving contents
    :opts, # opts to pass to modules used
    :validators, # validators to use on fetched file contents
    :queue_name, # the name of the queue to be used
    :strategy, # The sync strategy to build the inventory queue out with
    logger: FileSync.Interactions.Logger
  ]
end
