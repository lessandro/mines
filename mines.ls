{take,sum} = require 'prelude-ls'

state = 0

init-mines = !->
    <- make-grid!

    state := 0

    pos = [1 to tiles.length-1]
    shuffle pos
    pos = take 35 pos
    for n in pos
        tiles[n].bomb = 1

    for tile in tiles
        tile.highlighted = false
        tile.exposed = false

        if tile.bomb
            tile.text = 'B'
            continue

        n = [1 for neighbor in tile.neighbors when neighbor.bomb].length
        tile.text = if n > 0 then n.to-string! else ''

    draw-grid!

highlighted = null

move = (tile) !->
    if tile != highlighted
        if highlighted
            highlighted.highlighted = false

        if tile
            tile.highlighted = true

        highlighted := tile
        draw-grid!

expose = (tile) !->
    if tile.exposed
        return

    tile.exposed = true

    if tile.bomb
        setTimeout (-> window.alert 'you lost!'), 200
        state := 1

    if tile.text
        return

    for neighbor in tile.neighbors
        expose neighbor

mark = (tile) !->
    tile.marked = if tile.marked then false else true

click = (tile, ev) !->
    if state == 0
        right = ev.button == 2 or ev.which == 3
        keys = ev.ctrl-key or ev.shift-key or ev.meta-key or ev.alt-key
        if right or keys
            mark tile
        else
            expose tile

        move null

        draw-grid!
    else
        init-mines!

    return false

init = ->
    window.addEventListener 'mousemove', (handler move), false
    canvas.addEventListener 'mousedown', (handler click), false

    reset-canvas!
    init-mines!
