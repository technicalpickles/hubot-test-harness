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

  send: (body, callback) ->
    # room has # in it already
    @client.addListener "message#{@room}", (from, message) =>
      if from is @hubotNick
        callback(message) if callback

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

  it 'responds to hubot ping with PONG', (done) ->
    harness.send "hubot ping", (message) ->
      assert.equal message, 'PONG', "received PONG from hubot"
      done()

  it 'responds to hubot adapter with irc', (done) ->
    harness.send "hubot adapter", (message) ->
      assert.equal message, 'irc', "received irc from hubot"
      done()
