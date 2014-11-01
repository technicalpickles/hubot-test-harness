assert = require 'assert'

{inspect} = require 'util'
dotenv = require 'dotenv'
dotenv.load()

TOKEN = process.env.CAMPFIRE_TOKEN
ROOM_ID = process.env.CAMPFIRE_ROOM_ID
ACCOUNT = process.env.CAMPFIRE_ACCOUNT
HUBOT_USER_ID = parseInt process.env.CAMPFIRE_HUBOT_USER_ID
Campfire = require('campfire').Campfire

describe 'a hubot using the campfire adapter', () ->

  campfire = new Campfire
    token   : TOKEN,
    account : ACCOUNT


  sayAndExpect = (spokenBody, expectedBody, done) ->
    campfire.join ROOM_ID, (err, room) ->
      room.speak spokenBody, (err, res) ->
        done(err) if err?

        listener = null

        messagesReceived = []

        timeout = setTimeout () ->
          listener.end()
          done(new Error "Didn't respond with expected '#{expectedBody}' after 5 seconds, but received: #{inspect messagesReceived}")
        , 5 * 1000

        listener = room.listen (message) ->
          if message.userId is HUBOT_USER_ID
            messagesReceived.push message.body

            if message.body is expectedBody
              clearTimeout(timeout)
              listener.end()
              done()

  it 'responds to hubot ping with PONG', (done) ->
    sayAndExpect "hubot ping", "PONG", done

  it 'responds to hubot adapter with campfire', (done) ->
    sayAndExpect "hubot adapter", "slacks", done
