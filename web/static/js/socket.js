import {Socket} from "phoenix"

let me
let players = {}
let gravatarImages = {}
let messagesContainer = $("#messages")
let canvas = $("#canvas")[0]
let ctx = canvas.getContext("2d")
let w = $("#canvas").width()
let h = $("#canvas").height()
let playerWidth = 20
let playerHeight = 20

// draw board
function drawBoard() {
  ctx.fillStyle = "white"
  ctx.fillRect(0, 0, w, h)

  for (let id in players) {
    drawPlayer(players[id])
  }
}

// draw a player
function drawPlayer(player) {
  let x = player.x * playerWidth
  let y = player.y * playerHeight
  let gravatarImage = gravatarImages[player.gravatar_url]

  // Draws the player sprite
  if (gravatarImage) {
    ctx.drawImage(gravatarImage, x, y);
  } else {
    // until we have a gravatar image, we use a square player sprite
    ctx.fillStyle = "blue"
    ctx.fillRect(x, y, playerWidth, playerHeight)
    ctx.strokeStyle = "white"
    ctx.strokeRect(x, y, playerWidth, playerHeight)

    // Background image
    let image = new Image();
    image.onload = function () {
      // When we have finished loading the image, we store it in the image cache
      gravatarImages[player.gravatar_url] = image
      drawBoard()
    };
    image.src = player.gravatar_url
  }
}

function setupChannelMessageHandlers(channel) {
  // New player joined the game
  channel.on("player:joined", ({player: player}) => {
    messagesContainer.append(`<br/>${player.id} joined`)
    messagesContainer.scrollTop( messagesContainer.prop("scrollHeight"))
    players[player.id] = player
    drawBoard()
  })

  // Player changed position in board
  channel.on("player:position", ({player: player}) => {
    players[player.id] = player
    drawBoard()
  })
}

// Maps the arrow keys to a direction
function bindArrowKeys(channel, document) {
  $(document).keydown(function(e) {
    let key = e.which, d

    if(key == "37") {
      d = "left"
    } else if(key == "38") {
      d = "up"
    } else if(key == "39") {
      d = "right"
    } else if(key == "40") {
      d = "down"
    }

    if (d) {
      // notifies everyone our move
      channel.push("player:move", {direction: d})
    }
  });
}

// Start the connection to the socket and joins the channel
// Does initialization and key binding
function connectToSocket(user_id, document) {
  // connects to the socket endpoint
  let socket = new Socket("/socket", {params: {user_id: user_id}})
  socket.connect()
  let channel = socket.channel("players:lobby", {})
  me = user_id

  // joins the channel
  channel.join()
  .receive("ok", initialPlayers => { // on joining channel, we receive the current players list
    console.log('Joined to channel');
    setupChannelMessageHandlers(channel)
    bindArrowKeys(channel, document)
    players = initialPlayers.players
    drawBoard()
  })
}

export {connectToSocket}
