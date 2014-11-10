assert = require 'assert'

{inspect} = require 'util'
dotenv = require 'dotenv'
dotenv.load()

irc = require('irc')

class IrcHarness
  constructor: (@options) ->

    if @options
      @nick = @options.nick
      @server = @options.server
      @room = @options.room
      @hubotNick = @options.hubotNick

    @hubotMessages = []

  connect: (options) ->

    readyCallback = options.ready
    done = options.done
    expectedBody = options.expect
    sendBody = options.send

    @client = new irc.Client(@server, @nick, channels: [@room])

    @client.addListener "error", (message) ->
      done(message)

    @client.addListener "message#{@room}", (from, message) =>
      if from is @hubotNick
        @hubotMessages.push message
        if message is expectedBody
          done()

    # wait a second to make sure room server is connected and room joined
    setTimeout () =>
      if sendBody
        @send sendBody
      else
        readyCallback()
    , 1000

  send: (body) ->
    @client.say @room, body


describe 'a hubot using the irc adapter', () ->

  harnessOptions =
    nick:       process.env.TEST_IRC_NICK
    server:     process.env.TEST_IRC_SERVER
    room:       process.env.TEST_IRC_ROOM
    hubotNick: process.env.EXPECTED_IRC_HUBOT_NICK

  it 'responds to hubot ping with PONG', (done) ->
    harness = new IrcHarness harnessOptions

    harness.connect
      send:   "hubot ping"
      expect: "PONG"
      done:   done

  it 'responds to hubot adapter with irc', (done) ->
    harness = new IrcHarness harnessOptions

    harness.connect
      send:   "hubot adapter"
      expect: "irc"
      done:   done
