assert = require 'assert'

{inspect} = require 'util'
dotenv = require 'dotenv'
dotenv.load()


XmppClient = require 'node-xmpp-client'
ltx = require 'ltx'

describe 'a hubot using the xmpp adapter', () ->
  USERNAME = process.env.TEST_XMPP_USERNAME
  NICK     = USERNAME.split("@")[0]
  PASSWORD = process.env.TEST_XMPP_PASSWORD
  ROOM = process.env.TEST_XMPP_ROOM
  HUBOT_NICK = process.env.EXPECTED_XMPP_HUBOT_USER_NICK

  client = new XmppClient
    reconnect: true
    jid: USERNAME
    password: PASSWORD


  it 'responds to hubot ping with PONG', (done) ->
    messagesReceived = []

    client.on 'error', (err) ->
      done(err)
    client.on 'online', (data) ->
      client.send(new ltx.Element('presence', to: "#{ROOM}/#{NICK}").c('x', xmlns: 'http://jabber.org/protocol/muc').c('history', seconds: 1 ))
    client.on 'stanza', (stanza) ->
      if stanza.is('message') and stanza.attrs.type is 'groupchat'

        body = stanza.getChild('body')?.getText()
        from = stanza.attrs.from
        [room, user] = from.split '/'

        console.log HUBOT_NICK
        if user is HUBOT_NICK
          messagesReceived.push body
          if body is "PONG"
            done()

    setTimeout ->
      client.send(new ltx.Element('message', to: ROOM, type: 'groupchat').c('body').t('hubot ping'))
    , 1000
