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
      countdown: 0

    @update()
    @broadcastState()

  send: (msg) ->
    socket.emit 'msg', msg

  receive: (msg) ->
    if msg.type == 'stopwatch'
      @stopwatch(msg)
    if msg.type == 'timer'
      @timer(msg)
    else if msg.type == 'startstop'
      @startstop(msg)

  playSound: (name) ->
    console.log "playing sound '#{name}'"
    @currentSound = new Audio "audio/#{name}.wav"
    @currentSound.play()

  newConnection: ->
    @broadcastState()

  broadcastState: ->
    console.log "broadcasting state"
    @send {
      type: 'state'
      state: @state
    }

  setCenter: (html) ->
    $('#centertext').html(html)
    $('#centertext').css({ 'width':'100%', 'text-align':'center' })
    h1 = $('#centertext').height()
    h = h1/2
    w1 = $(window).height()
    w = w1/2
    m = w - h
    $('#centertext').css("margin-top",m + "px")

  renderClock: (t) ->
    secs = Math.floor(t / 1000)
    mins = Math.floor(secs / 60)
    secs -= (mins * 60)
    ms = t - (1000 * (secs + (mins * 60)))

    secs = ('0'+secs).slice(-2)
    mins = ('0'+mins).slice(-2)
    ms   = ('000'+ms).slice(-3)

    @setCenter("<span class=\"clock\">#{mins}:#{secs}.#{ms}</span>")

  renderCountdown: ->
    t = Math.floor((@state.countdown / 1000) + 1)
    @setCenter("<span class=\"countdown\">#{t}</span>")

  update: ->
    if @state.countdown > 0
      @renderCountdown()
    else
      if @state.mode == 'timer'
        t = (@state.timer * 1000) - @state.time
        if t < 0
          t = 0
          @stop()
          @playSound "buzzer"
        @renderClock(t)
      else
        @renderClock(@state.time)

  isRunning: ->
    return (@interval != null)

  stop: ->
    if @interval
      clearInterval @interval
      @interval = null

  start: (msg) ->
    if msg.countdown and @state.time == 0
      # fresh clock start, do a countdown
      @state.countdown = 3000
      @playSound "countdown3"

    @lastTime = Date.now()
    @interval = setInterval =>
      now = Date.now()
      delta = now - @lastTime
      if @state.countdown > 0
        @state.countdown -= delta
        if @state.countdown < 0
          @state.countdown = 0
        if @state.countdown == 0
          # we just finished the countdown, do stuff
          @playSound "buzzer"
      else
        @state.time += delta
      @lastTime = now
      @update()
    , 10

  switchMode: (mode) ->
    @stop()
    @state.mode = mode
    @state.time = 0
    @state.countdown = 0
    @broadcastState()
    @update()

  stopwatch: (msg) ->
    @switchMode('stopwatch')

  timer: (msg) ->
    @state.timer = msg.seconds
    @switchMode('timer')

  startstop: (msg) ->
    if @isRunning()
      @stop()
    else
      @start(msg)
    @update()


# --------------------------------------------------------------
# UI Hooks

ready = ->
  console.log "ui is ready"
  gScreen = new Screen

module.exports =
  ready: ready
