# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config


# DropBox options:
folder = "Harrison Birth" # The name of the folder you want to sync. Doesn't do nested folders yet
limit = 3 # The page size for querying. Re-queries every hour
token_file_path = "tmp/dropbox_token" # path to a file containing your dropbox api token

# FileSystem options:
target_directory = "data" # Directory where you want to save your files

config :file_sync, source: %{
  source: :dropbox,
  folder: folder,
  limit: limit,
  token_file_path: token_file_path
}

config :file_sync, target: %{
  source: :file_system,
  target_directory: target_directory
}

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure your application as:
#
#     config :file_sync, key: :value
#
# and access this configuration in your application as:
#
#     Application.get_env(:file_sync, :key)
#
# You can also configure a 3rd-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env}.exs"
