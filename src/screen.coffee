# --------------------------------------------------------------
# Globals

gScreen = null

# --------------------------------------------------------------
# Socket connection stuff

socket = io.connect ''
socket.on 'new', (data) ->
  gScreen.newConnection()
socket.on 'msg', (data) ->
  console.log data
  gScreen.receive(data)

# --------------------------------------------------------------
# Screen

class Screen
  constructor: ->
    @interval = null
    @lastTime = 0
    @state =
      mode: 'stopwatch'
      users: [
        {
          name: 'Joe'
        }
      ]
      time: 0

    @render()
    @broadcastState()

  send: (msg) ->
    socket.emit 'msg', msg

  receive: (msg) ->
    if msg.type == 'reset'
      @reset(msg)
    else if msg.type == 'startstop'
      @startstop(msg)

  newConnection: ->
    @broadcastState()

  broadcastState: ->
    console.log "broadcasting state"
    @send {
      type: 'state'
      state: @state
    }

  render: ->
    secs = Math.floor(@state.time / 1000)
    mins = Math.floor(secs / 60)
    secs -= (mins * 60)
    ms = @state.time - (1000 * (secs + (mins * 60)))

    console.log "secs #{secs} mins #{mins} ms #{ms}"

    secs = ('0'+secs).slice(-2)
    mins = ('0'+mins).slice(-2)
    ms   = ('000'+ms).slice(-3)

    $('#timer').html("#{mins}:<span class=\"seconds\">#{secs}</span>.#{ms}")

    $('#timer').css({ 'width':'100%', 'text-align':'center' })
    h1 = $('#timer').height()
    h = h1/2
    w1 = $(window).height()
    w = w1/2
    m = w - h
    $('#timer').css("margin-top",m + "px")

  reset: (msg) ->
    if @interval
      clearInterval @interval
      @interval = null
    @state.time = 0
    @render()

  startstop: (msg) ->
    if @interval
      clearInterval @interval
      @interval = null
    else
      console.log "setting interval"
      @lastTime = Date.now()
      @interval = setInterval =>
        now = Date.now()
        @state.time += now - @lastTime
        @lastTime = now
        @render()
      , 10
    @render()


# --------------------------------------------------------------
# UI Hooks

ready = ->
  console.log "ui is ready"
  gScreen = new Screen

module.exports =
  ready: ready
