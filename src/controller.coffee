# --------------------------------------------------------------
# Globals

gController = null

# --------------------------------------------------------------
# Socket connection stuff

socket = io.connect ''
socket.on 'msg', (data) ->
  # console.log data
  gController.receive(data)

# --------------------------------------------------------------
# Controller

class Controller
  constructor: ->
    @state =
      mode: 'stopwatch'
      users: []

  send: (msg) ->
    socket.emit 'msg', msg

  receive: (msg) ->
    if msg.type == 'state'
      @state = msg.state
      console.log "received screen state: ", @state

  reset: ->
    @send {
      type: 'reset'
    }

  startstop: ->
    @send {
      type: 'startstop'
    }

# --------------------------------------------------------------
# UI Hooks

module.exports =
  ready: ->
    console.log "ui is ready"
    gController = new Controller
  reset: ->
    gController.reset()
  startstop: ->
    gController.startstop()
