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

  startstop: ->
    countdown = parseInt($("#countdown").val())
    countdown = (countdown > 0)
    @send {
      type: 'startstop'
      countdown: countdown
    }

  stopwatch: ->
    @send {
      type: 'stopwatch'
    }

  timer: ->
    mins = parseInt($("#timer_mins").val())
    secs = parseInt($("#timer_secs").val())
    totalSeconds = (mins * 60) + secs
    @send {
      type: 'timer'
      seconds: totalSeconds
    }

# --------------------------------------------------------------
# UI Hooks

module.exports =
  ready: ->
    console.log "ui is ready"
    gController = new Controller
  stopwatch: ->
    gController.stopwatch()
  timer: ->
    gController.timer()
  startstop: ->
    gController.startstop()
