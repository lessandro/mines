{take, sum, tail, filter} = require 'prelude-ls'
{shuffle} = require '../lib/util'
{init-canvas, draw-grid} = require '../lib/canvas'
{make-grid} = require '../lib/grid'

[w, h] = [0 0]
total-bombs = 0
state = 0
grid = null
bombs-left = 0
unexposed = 0
highlighted = null

init-mines = !->
    grid := make-grid w, h
    state := -1
    bombs-left := total-bombs
    unexposed := grid.tiles.length - total-bombs

    draw-grid grid
    update-status!

assign-bombs = (tile) !->
    pos = filter (!= tile.n), [0 to grid.tiles.length-1]
    shuffle pos
    pos = take total-bombs, pos
    for n in pos
        grid.tiles[n].bomb = 1

    for tile in grid.tiles
        tile.highlighted = false
        tile.exposed = false

        if tile.bomb
            tile.text = 'B'
            continue

        n = [1 for neighbor in tile.neighbors when neighbor.bomb].length
        tile.num = n
        tile.text = if n > 0 then n.to-string! else ''

    state := 0
    draw-grid grid
    update-status!

move = (tile) !->
    if tile != highlighted
        if highlighted
            highlighted.highlighted = false

        if tile
            tile.highlighted = true

        highlighted := tile
        draw-grid grid

expose = (tile) !->
    if tile.exposed
        return

    tile.exposed = true

    if tile.bomb
        state := 1
        for tile in grid.tiles
            if tile.bomb
                tile.exposed = true
        return

    unexposed := unexposed - 1
    if unexposed == 0
        setTimeout (-> window.alert 'You win!'), 200
        state := 1
        return

    if tile.text
        return

    for neighbor in tile.neighbors
        expose neighbor

mark = (tile) !->
    if tile.exposed
        marks = [1 for neighbor in tile.neighbors when neighbor.marked].length
        if marks == tile.num
            for neighbor in tile.neighbors
                if !neighbor.marked
                    expose neighbor
    else
        tile.marked = if tile.marked then false else true
        bombs-left := bombs-left + (if tile.marked then -1 else 1)

click = (tile, ev) !->
    if state == -1
        assign-bombs tile

    if state == 0
        right = ev.button == 2 or ev.which == 3
        keys = ev.ctrl-key or ev.shift-key or ev.meta-key or ev.alt-key

        if right or keys
            mark tile
        else
            expose tile

        highlighted.highlighted = false
        draw-grid grid
        update-status!
    else
        init-mines!

update-status = !->
    status = document.get-element-by-id 'status'
    if state == 1
        status.text-content = "Game over!"
    else
        status.text-content = "Bombs left: #bombs-left"

reset = !->
    [w_, h_, b_] = tail window.location.hash .split(',')

    w := parse-int w_, 10
    h := parse-int h_, 10
    total-bombs := parse-int b_, 10

    init-canvas 'canvas', w, h, 30, move, click
    init-mines!

init = !->
    window.add-event-listener 'hashchange', reset, false

    if !window.location.hash
        window.location = '#20,15,35'
    else
        reset!

init!
