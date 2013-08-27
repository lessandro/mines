{take, sum, tail, filter, span} = require 'prelude-ls'
{init-canvas, resize-canvas, draw-grid} = require '../lib/canvas'
{make-grid} = require '../lib/grid'

sock = null
grid = null
highlighted = null
player = null
turn = null
err = null

move = (tile) !->
    if !grid or turn != player
        return

    if tile != highlighted
        if highlighted
            highlighted.highlighted = false
            highlighted.updated = true

        if tile
            tile.highlighted = true
            tile.updated = true

        highlighted := tile
        draw-grid grid, true

click = (tile, ev) !->
    if !grid or turn != player
        return

    sock.send 'click ' + tile.n

set-status = (text) !->
    status = document.get-element-by-id 'status'
    status.text-content = text

update-status = !->
    if player < 2
        if turn == null
            set-status "Waiting for your opponent to connect. Send him the link!"
            return

        if turn == player
            set-status "Your turn!"
        else
            set-status "Opponent's turn..."
    else
        if turn == null
            set-status "One of the players left the game!"
            return

        if turn == 0
            set-status "A is playing!"
        else
            set-status "B is playing!"

update-score = (state) !->
    if player < 2
        txt = "Your score (#{"AB"[player]}): #{state.scores[player]}<br>"
        txt += "Opponent's score (#{"AB"[1 - player]}): #{state.scores[1 - player]}<br>"
    else
        txt = "A's score: #{state.scores[0]}<br>"
        txt += "B's score: #{state.scores[1]}<br>"

    txt += "Score to win: " + (Math.floor(state.bombs / 2) + 1)

    score = document.get-element-by-id 'score'
    score.innerHTML = txt

init = !->
    init-canvas 'canvas', move, click
    set-status 'Connecting...'

    sock := new SockJS 'http://' + window.location.hostname + ':8003/mines'

    sock.onopen = !->
        sock.send 'game ' + tail (window.location.hash or "#")

    sock.onmessage = (ev) !->
        [cmd, data] = span (!= ' '), ev.data
        data = data.trim!

        if cmd == 'err'
            err := data
            set-status data
            return

        if cmd == 'player'
            player := parse-int data, 10

        if cmd == 'state'
            state = JSON.parse data

            if !grid or grid.name != state.name or grid.seed != state.seed
                window.location = '#' + state.name
                grid := make-grid state.cols, state.rows, state.seed
                resize-canvas state.cols, state.rows, 30

            turn := state.turn

            if !state.players[0] or !state.players[1]
                turn := null

            for tile in grid.tiles
                tile.text = state.tiles[tile.n]
                tile.exposed = tile.text != null

            draw-grid grid
            update-status!
            update-score state

            if state.winner != null
                if state.winner == player
                    alert "You won!"
                else
                    alert "You lost!"

                sock.send 'restart'
                set-status 'Waiting for your opponent...'

    sock.onclose = !->
        resize-canvas 0, 0, 30
        set-status (err or "") + ' Disconnected!'

init!
