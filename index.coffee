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

  it 'responds to hubot ping with PONG', (done) ->

    campfire.join ROOM_ID, (err, room) ->
      room.speak "hubo ping", (err, res) ->
        done(err) if err?

        listener = null

        timeout = setTimeout () ->
          listener.end()
          done(new Error "no PONG after 5 seconds")
        , 5 * 1000

        listener = room.listen (message) ->
          if message.body is "PONG" and message.userId is HUBOT_USER_ID
            clearTimeout timeout
            listener.end();
            done()
