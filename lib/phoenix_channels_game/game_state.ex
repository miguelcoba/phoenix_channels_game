defmodule PhoenixChannelsGame.GameState do
  @board_size 20  # cells
  @player_size 20 # pixels

  def player_size, do: @player_size
  def screen_width, do: @board_size * @player_size
  def screen_height, do: @board_size * @player_size

  # Used by the supervisor to start the Agent
  # The initial value passed to the Agent is an empty map
  def start_link do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  # Put a new player in the map
  def put_player(player) do
    player =
      player
        |> reset_player_position
    Agent.update(__MODULE__, &Map.put_new(&1, player.id, player))
    player
  end

  # Retrive a player from the map
  def get_player(player_id) do
    Agent.get(__MODULE__, &Map.get(&1, player_id))
  end

  # Update a player information in the map
  def update_player(player) do
    Agent.update(__MODULE__, &Map.put(&1, player.id, player))
    player
  end

  # Get all the players in the map
  def players do
    Agent.get(__MODULE__, &(&1))
  end

  # Game logic

  def move_player(player_id, direction) do
    delta = case direction do
      "right" -> %{ x: 1, y: 0 }
      "left" -> %{ x: -1, y: 0 }
      "up" -> %{ x: 0, y: -1 } # canvas coordinates start from top
      "down" -> %{ x: 0, y: 1 }
    end

    player_id
      |> get_player
      |> new_position(delta)
      |> update_player
  end

  defp new_position(player, delta) do
    player
      |> Map.update!(:x, &bounded_increment(&1 + delta.x))
      |> Map.update!(:y, &bounded_increment(&1 + delta.y))
  end

  defp bounded_increment(value) when value < 0, do: 0
  defp bounded_increment(value) when value > @board_size - 1, do: @board_size - 1
  defp bounded_increment(value), do: value

  defp reset_player_position(player), do: Map.merge(player, %{x: @board_size / 2, y: @board_size / 2})
end
