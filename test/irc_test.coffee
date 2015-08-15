{EventEmitter} = require 'events'

chai = require 'chai'
assert = chai.assert

{inspect} = require 'util'
dotenv = require 'dotenv'
dotenv.load()

irc = require 'irc'
{Server} = require 'ircdjs/lib/server.js'
{spawn} = require 'child_process'
path = require 'path'

IRC_SERVER_PORT = 7474

IRC_SERVER_CONFIG = 
  "network":  "hubot",
  "hostname": "localhost",
  "serverDescription": "Hubot Test Server",
  "serverName": "server1",
  "port": IRC_SERVER_PORT,
  "motd": "Message of the day",
  "whoWasLimit": 10000,
  "token": 1,
  "pingTimeout": 120,
  "maxNickLength": 30

class Hubot
  constructor: (@nick, @env) ->
    @env['HUBOT_IRC_NICK'] = @nick
    @env['HUBOT_LOG_LEVEL'] = 'warning'
    @env['PATH'] = 'node_modules/.bin:/usr/local/bin'

  start: ->
    # This is disgusting and will hopefully be replaced at some point with the ability to programmatically launch Hubot
    @process = spawn(
      '/bin/bash'
      ['-c',"node_modules/.bin/hubot -a irc --name #{@nick}"]
      cwd: path.join __dirname, '..', '/hubot-under-test'
      env: @env
      )

    @process.stdout.on 'data', (data) ->
      console.log('' + data)

    @process.stderr.on 'data', (data) ->
      console.log('' + data)

    @process.on 'close', (code) ->
      console.log "hubot died with code #{code}"

  stop: ->
    @process.kill()

class IrcHarness
  class Conversation extends EventEmitter
    andReceiveOne: (cb) ->
      @andReceiveCount 1, (messages) -> cb(messages[0])

    andReceiveTwo: (cb) -> @andReceiveCount 2, cb

    andReceiveThree: (cb) -> @andReceiveCount 3, cb

    andReceiveFour: (cb) -> @andReceiveCount 4, cb

    andReceiveCount: (count, cb) ->
      messages = []

      @on 'message', (message) =>
        messages.push message
        if messages.length == count
          cb messages

      return this

  send: (message) ->
    conv = new Conversation

    @client.addListener "message#{@room}", (from, message) =>
      if from is @hubotNick
        conv.emit 'message', message

    # Defer so we can set up event handlers
    process.nextTick =>
      @client.say @room, message

    return conv

  sendAddressed: (message) ->
    @send "#{@hubotNick}: #{message}"

  sendAliased: (message) ->
    throw new Error('aliases not implemented yet')
    @send "#{@hubotAlias}: #{message}"


  constructor: (@options) ->

    if @options
      @nick = @options.nick
      @server = @options.server
      @room = @options.room
      @hubotNick = @options.hubotNick

    @hubotMessages = []

  connect: (callback) ->
    @client = new irc.Client(@server, @nick, channels: [@room], autoConnect: false, port: IRC_SERVER_PORT)

    @client.connect () ->
      # give it a chance to actually show up in chat
      setTimeout () ->
        callback()
      , 500

  disconnect: (callback) ->
    @client.disconnect "test done", callback

describe 'a hubot using the irc adapter', ->

  harnessOptions =
    nick:       process.env.TEST_IRC_NICK
    server:     process.env.TEST_IRC_SERVER
    room:       process.env.TEST_IRC_ROOM
    hubotNick: process.env.EXPECTED_IRC_HUBOT_NICK

  before (done) ->
    console.log "Starting IRC server"
    @ircServer = new Server()
    @ircServer.config = IRC_SERVER_CONFIG

    @hubot = new Hubot(
      harnessOptions.hubotNick
      HUBOT_IRC_ROOMS: harnessOptions.room
      HUBOT_IRC_SERVER: '127.0.0.1'
      HUBOT_IRC_PORT: IRC_SERVER_PORT
    )

    startHubot = =>
      console.log "Launching Hubot"
      @hubot.start()
      setTimeout done, 1000

    @ircServer.start()
    # Give everything a second to start up
    setTimeout startHubot, 1000

  after ->
    @hubot.stop()
    @ircServer.close()

  beforeEach (done) ->
    @harness = new IrcHarness harnessOptions
    @harness.connect () ->
      done()

  afterEach () ->
    @harness.disconnect()

  it 'responds to ping with PONG', (done) ->
    @harness.sendAddressed('ping').andReceiveOne (message) ->
      assert.equal message, 'PONG', "received PONG from hubot"
      done()

  it 'responds to adapter with irc', (done) ->
    @harness.sendAddressed('adapter').andReceiveOne (message) ->
      assert.equal message, 'irc', "received irc from hubot"
      done()

  it 'responds to pug bomb with appropriate number of pugs', (done) ->
    @harness.sendAddressed('pug bomb 2').andReceiveTwo (messages) ->
      assert.match messages[0], /^http.*(jpe?g|gif|png)$/, 'first message is not a valid pug url'
      assert.match messages[1], /^http.*(jpe?g|gif|png)$/, 'second message is not a valid pug url'
      done()
