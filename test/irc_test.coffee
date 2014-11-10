assert = require 'assert'

{inspect} = require 'util'
dotenv = require 'dotenv'
dotenv.load()

irc = require('irc')


describe 'a hubot using the irc adapter', () ->
  NICK = process.env.TEST_IRC_NICK
  SERVER = process.env.TEST_IRC_SERVER
  ROOM = process.env.TEST_IRC_ROOM
  HUBOT_NICK = process.env.EXPECTED_IRC_HUBOT_NICK

  it 'responds to hubot ping with PONG', (done) ->
    client = new irc.Client(SERVER, NICK, channels: [ROOM])

    messagesReceived = []

    client.addListener "message#{ROOM}", (from, message) ->
      if from is HUBOT_NICK
        messagesReceived.push message
        if message is "PONG"
          done()

    client.addListener "error", (message) ->
      done(message)

    setTimeout ->
      client.say ROOM, "hubot ping"
    , 1000
