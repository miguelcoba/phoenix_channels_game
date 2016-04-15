defmodule PhoenixChannelsGame.GameState do
  @moduledoc """
    This module holds the game current state. It also contains the game logic.
    Allows to add new players to the board, move them and detect collisions.
  """

  @board_size 20  # cells
  @player_size 20 # pixels

  def player_size, do: @player_size
  def screen_width, do: @board_size * @player_size
  def screen_height, do: @board_size * @player_size

  @doc """
    Used by the supervisor to start the Agent that will keep the game state persistent.
    The initial value passed to the Agent is an empty map.
  """
  def start_link do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  @doc """
    Put a new player in the map
  """
  def put_player(player) do
    player =
      player
        |> reset_player_position
    Agent.update(__MODULE__, &Map.put_new(&1, player.id, player))
    player
  end

  @doc """
    Retrive a player from the map
  """
  def get_player(player_id) do
    Agent.get(__MODULE__, &Map.get(&1, player_id))
  end

  @doc """
    Update a player information in the map
  """
  def update_player(player) do
    Agent.update(__MODULE__, &Map.put(&1, player.id, player))
    player
  end

  @doc """
    Get all the players in the map
  """
  def players do
    Agent.get(__MODULE__, &(&1))
  end

  # Game logic

  @doc """
    Move the player one cell in the indicated direction
  """
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

  @doc """
    Moves the player in the indicated direction and checks if there was a collision
    with other player already in that position.

    Returns
      {player, nil} if no collision was detected
      {player, killed_player} if a collision was detected. The killed player has
        the position reset to the initial position
  """
  def move_player_and_detect_collision(player_id, direction) do
    player = move_player(player_id, direction)
    case detect_collision(player) do
      nil ->
        {player, nil}
      killed_player ->
        killed_player = respawn_killed_player(killed_player)
        {player, killed_player}
    end
  end

  # Detects if the player current position is the same as some other player
  # Returns nil if no collision or the player map if one found
  defp detect_collision(player) do
    players |> Map.values |> Enum.find(fn p -> players_in_same_position(p, player) end)
  end

  # Test if two different players have the same coordinates in board
  defp players_in_same_position(player, otherPlayer) do
    player.id != otherPlayer.id && player.x == otherPlayer.x && player.y == otherPlayer.y
  end

  # Resets the player position to the initial position
  defp respawn_killed_player(player) do
    player |> reset_player_position |> update_player
  end

  defp bounded_increment(value) when value < 0, do: 0
  defp bounded_increment(value) when value > @board_size - 1, do: @board_size - 1
  defp bounded_increment(value), do: value

  defp reset_player_position(player), do: Map.merge(player, %{x: @board_size / 2, y: @board_size / 2})
end
