chai = require 'chai'
assert = chai.assert

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

  connect: (callback) ->
    @client = new irc.Client(@server, @nick, channels: [@room], autoConnect: false)




    @client.connect () ->
      # give it a chance to actually show up in chat
      setTimeout () ->
        callback()
      , 500

  disconnect: (callback) ->
    @client.disconnect "test done", callback

  sendAndReceive: (body, options, callback) ->
    if typeof(options) == 'function'
      callback = options
      options = {}

    receiveCount = options.count or 1

    messages = []
    # room has # in it already
    @client.addListener "message#{@room}", (from, message) =>
      if from is @hubotNick
        if receiveCount is 1
          callback(message) if callback
        else
          messages.push message

          if messages.length is receiveCount
            callback(messages)

    @client.say @room, body

describe 'a hubot using the irc adapter', () ->

  harnessOptions =
    nick:       process.env.TEST_IRC_NICK
    server:     process.env.TEST_IRC_SERVER
    room:       process.env.TEST_IRC_ROOM
    hubotNick: process.env.EXPECTED_IRC_HUBOT_NICK

  harness = null

  beforeEach (done) ->
    harness = new IrcHarness harnessOptions
    harness.connect () ->
      done()

  afterEach () ->
    harness.disconnect()

  it 'responds to ping with PONG', (done) ->
    harness.sendAndReceive "hubot ping", (message) ->
      assert.equal message, 'PONG', "received PONG from hubot"
      done()

  it 'responds to adapter with irc', (done) ->
    harness.sendAndReceive "hubot adapter", (message) ->
      assert.equal message, 'irc', "received irc from hubot"
      done()

  it 'responds to pug bomb with appropriate number of pugs', (done) ->
    harness.sendAndReceive "hubot pug bomb 2", count: 2, (messages) ->
      assert.match messages[0], /^http.*(jpe?g|gif|png)$/, "received first pug url"
      assert.match messages[1], /^http.*(jpe?g|gif|png)$/, "received second pug url"
      done()
