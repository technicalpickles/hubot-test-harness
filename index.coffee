assert = require 'assert'

{inspect} = require 'util'
dotenv = require 'dotenv'
dotenv.load()


Campfire = require('campfire').Campfire

XmppClient = require 'node-xmpp-client'
ltx = require 'ltx'

irc = require('irc')

# describe 'a hubot using the campfire adapter', () ->
#
#   TOKEN = process.env.TEST_CAMPFIRE_TOKEN
#   ROOM_ID = process.env.TEST_CAMPFIRE_ROOM_ID
#   ACCOUNT = process.env.TEST_CAMPFIRE_ACCOUNT
#   HUBOT_USER_ID = parseInt process.env.EXPECTED_CAMPFIRE_HUBOT_USER_ID
#
#   campfire = new Campfire
#     token   : TOKEN,
#     account : ACCOUNT
#
#   sayAndExpect = (spokenBody, expectedBody, done) ->
#     campfire.join ROOM_ID, (err, room) ->
#       room.speak spokenBody, (err, res) ->
#         done(err) if err?
#
#         listener = null
#
#         messagesReceived = []
#
#         timeout = setTimeout () ->
#           listener.end()
#           done(new Error "Didn't respond with expected '#{expectedBody}' after 5 seconds, but received: #{inspect messagesReceived}")
#         , 5 * 1000
#
#         listener = room.listen (message) ->
#           if message.userId is HUBOT_USER_ID
#             messagesReceived.push message.body
#
#             if message.body is expectedBody
#               clearTimeout(timeout)
#               listener.end()
#               done()
#
#   it 'responds to hubot ping with PONG', (done) ->
#     sayAndExpect "hubot ping", "PONG", done
#
#   it 'responds to hubot adapter with campfire', (done) ->
#     sayAndExpect "hubot adapter", "campfire", done

# describe 'a hubot using the xmpp adapter', () ->
#   USERNAME = process.env.TEST_XMPP_USERNAME
#   NICK     = USERNAME.split("@")[0]
#   PASSWORD = process.env.TEST_XMPP_PASSWORD
#   ROOM = process.env.TEST_XMPP_ROOM
#   HUBOT_NICK = process.env.EXPECTED_XMPP_HUBOT_USER_NICK
#
#   client = new XmppClient
#     reconnect: true
#     jid: USERNAME
#     password: PASSWORD
#
#
#   it 'responds to hubot ping with PONG', (done) ->
#     messagesReceived = []
#
#     client.on 'error', (err) ->
#       done(err)
#     client.on 'online', (data) ->
#       client.send(new ltx.Element('presence', to: "#{ROOM}/#{NICK}").c('x', xmlns: 'http://jabber.org/protocol/muc').c('history', seconds: 1 ))
#     client.on 'stanza', (stanza) ->
#       if stanza.is('message') and stanza.attrs.type is 'groupchat'
#
#         body = stanza.getChild('body')?.getText()
#         from = stanza.attrs.from
#         [room, user] = from.split '/'
#
#         console.log HUBOT_NICK
#         if user is HUBOT_NICK
#           messagesReceived.push body
#           if body is "PONG"
#             done()
#
#     setTimeout ->
#       client.send(new ltx.Element('message', to: ROOM, type: 'groupchat').c('body').t('hubot ping'))
#     , 1000


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
