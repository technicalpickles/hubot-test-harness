assert = require 'assert'

{inspect} = require 'util'
dotenv = require 'dotenv'
dotenv.load()

Campfire = require('campfire').Campfire

describe 'a hubot using the campfire adapter', () ->

  TOKEN = process.env.TEST_CAMPFIRE_TOKEN
  ROOM_ID = process.env.TEST_CAMPFIRE_ROOM_ID
  ACCOUNT = process.env.TEST_CAMPFIRE_ACCOUNT
  HUBOT_USER_ID = parseInt process.env.EXPECTED_CAMPFIRE_HUBOT_USER_ID

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
    sayAndExpect "hubot adapter", "campfire", done
