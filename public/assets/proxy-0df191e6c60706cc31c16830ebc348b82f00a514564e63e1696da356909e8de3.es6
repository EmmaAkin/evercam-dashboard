import {Socket} from "phoenix"

$(() => {
  let camera_id = window.Evercam.Camera.id;

  let socket = new Socket("wss://media.evercam.io/ws")

  socket.connect();

  let chan = socket.chan(`cameras:${camera_id}`, {})

  chan.join()

  chan.on("snapshot-taken", payload => {
    $("#live-player-image").attr("src", "data:image/jpeg;base64," + payload.image);
  })
})
