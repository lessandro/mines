{filter, span} = require 'prelude-ls'
{Game} = require './game'
http = require 'http'
sockjs = require 'sockjs'

games = {}

broadcast-state = (game) !->
    game-state = game.serialize!
    for player in game.players when player != null
        player.write 'state ' + game-state

sjs-server = sockjs.create-server {log: ->}
sjs-server.on 'connection', (conn) ->
    console.log 'open'

    game = null
    n = null

    err = (msg) !->
        conn.write 'err ' + msg
        conn.close!

    conn.on 'data', (data) !->
        console.log '>', data

        [cmd, data] = span (!= ' '), data
        data = data.trim!

        if cmd == 'game'
            if game
                err 'Already in a game!'
                return

            if data
                game := games[data]

            if !game
                game := new Game data
                games[game.name] = game
                console.log 'creating game', game.name

            n := game.add-player conn
            if n == null
                err 'This game is full!'
                return

            conn.num = n
            conn.write 'player ' + n
            broadcast-state game

        if cmd == 'restart'
            if !game
                err 'Not in a game!'
                return

            if game.player-restart conn.num
                broadcast-state game

        if cmd == 'click'
            if !game
                err 'Not in a game!'
                return

            tile-num = parse-int data, 10
            if game.click-tile conn.num, tile-num
                broadcast-state game

    conn.on 'close', !->
        console.log 'close'
        if game
            if game.del-player conn.num
                console.log 'deleting game', game.name
                delete games[game.name]
            else
                broadcast-state game

            game := null

server = http.create-server!
sjs-server.install-handlers server, {prefix: '/mines'}
server.listen 9999, '0.0.0.0'
