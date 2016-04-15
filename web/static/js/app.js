import "phoenix_html"

import {connectToSocket} from "./socket"

// handler for the join button
$(document).ready(function() {
  $("#joinButton").click(function() {
    var email = $("#email").val()
    if (/@/.test(email)) {
      connectToSocket(email.trim(), document)
    } else {
      alert("You should enter your email to join the game")
    }
  })
})
