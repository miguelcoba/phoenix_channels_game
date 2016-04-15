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
    player = %{id: player_id}
    player = GameState.put_player(player)
    broadcast! socket, "player:joined", %{player: player}
    {:noreply, socket}
  end

  def handle_in("player:move", %{"direction" => direction}, socket) do
    player_id = socket.assigns.player_id
    player = GameState.move_player(player_id, direction)
    broadcast! socket, "player:position", %{player: player}
    {:noreply, socket}
  end
end
