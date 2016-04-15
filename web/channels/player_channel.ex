defmodule PhoenixChannelsGame.PlayerChannel do
  use Phoenix.Channel

  alias PhoenixChannelsGame.GameState

  def join("players:lobby", message, socket) do
    players = GameState.players()
    send(self, {:after_join, message})

    {:ok, %{players: players}, socket}
  end

  def join("players:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_info({:after_join, _message}, socket) do
    player_id = socket.assigns.player_id
    gravatar_url = socket.assigns.gravatar_url
    player = %{id: player_id, gravatar_url: gravatar_url}
    player = GameState.put_player(player)
    broadcast! socket, "player:joined", %{player: player}
    {:noreply, socket}
  end

  def handle_in("player:move", %{"direction" => direction}, socket) do
    player_id = socket.assigns.player_id
    case GameState.move_player_and_detect_collision(player_id, direction) do
      {player, nil} ->
        broadcast! socket, "player:position", %{player: player}
      {player, killed_player} ->
        broadcast! socket, "player:position", %{player: player}
        broadcast! socket, "player:player_killed", %{player: killed_player}
    end
    {:noreply, socket}
  end
end
