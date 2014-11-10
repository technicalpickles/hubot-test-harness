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

  connect: (callback, done) ->
    @client = new irc.Client(@server, @nick, channels: [@room])

    @client.addListener "error", (message) ->
      done(message)

    callback(@client, done)


describe 'a hubot using the irc adapter', () ->

  harnessOptions =
    nick:       process.env.TEST_IRC_NICK
    server:     process.env.TEST_IRC_SERVER
    room:       process.env.TEST_IRC_ROOM
    hubotNick: process.env.EXPECTED_IRC_HUBOT_NICK
  harness = new IrcHarness harnessOptions



  it 'responds to hubot ping with PONG', (done) ->
    harness.connect (client) ->
      client.addListener "message#{harness.room}", (from, message) =>
        if from is harness.hubotNick
          harness.hubotMessages.push message
          if message is "PONG"
            done()

      setTimeout ->
        client.say harness.room, "hubot ping"
      , 1000
    , done
