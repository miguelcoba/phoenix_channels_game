ExUnit.start

Mix.Task.run "ecto.create", ~w(-r PhoenixChannelsGame.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r PhoenixChannelsGame.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(PhoenixChannelsGame.Repo)

