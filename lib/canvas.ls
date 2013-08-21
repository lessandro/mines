{last} = require 'prelude-ls'
[N, W, S, E] = require './shape' .edge-list

canvas = null
ctx = null
tile-size = null
grid = null

export init-canvas = (elem, move, click) !->
    canvas := document.get-element-by-id elem
    if !canvas
        throw 'canvas elem not found'

    ctx := canvas.get-context '2d'
    if !ctx
        throw 'could not get canvas 2d context'

    canvas.add-event-listener 'mousemove', (handler move), false
    canvas.add-event-listener 'mouseout', (handler move), false
    canvas.add-event-listener 'click', (handler click), false
    canvas.add-event-listener 'contextmenu', (handler click), false

export resize-canvas = (cols, rows, size) !->
    tile-size := size
    canvas.width = cols * tile-size
    canvas.height = rows * tile-size

draw-contour = (contour) !->
    ctx.beginPath!
    (-> ctx.moveTo it[0], it[1]) last contour
    for [x, y] in contour
        ctx.lineTo x, y

draw-tile = (tile) !->
    if tile.exposed and !tile.text
        return

    ctx.save!
    ctx.translate tile.col * tile-size, tile.row * tile-size
    ctx.save!
    ctx.scale tile-size, tile-size
    ctx.line-width = 1.0/tile-size
    ctx.fill-style = '#cccccc'

    if tile.marked
        ctx.fill-style = 'pink'
    if tile.highlighted
        ctx.fill-style = 'cyan'
    if tile.exposed
        ctx.fill-style = 'white'
        if tile.bomb
            ctx.fill-style = 'pink'

    draw-contour tile.shape.contour
    ctx.fill!
    ctx.stroke!
    ctx.restore!

    if tile.exposed
        font-size = (tile-size*20/30) .|. 0
        offset = (tile-size*6/30) .|. 0
        ctx.font = font-size.to-string! + "px arial"
        width = ctx.measure-text(tile.text).width
        ctx.fill-text tile.text,
            tile.shape.center[0] * tile-size + tile-size/2 - width/2,
            tile.shape.center[1] * tile-size + tile-size/2 + offset

    ctx.restore!

export draw-grid = (grid_) !->
    grid := grid_

    ctx.clear-rect 0, 0, canvas.width, canvas.height

    for tile in grid.tiles
        draw-tile tile

get-tile-at = (x, y) ->
    if x < 0 or y < 0
        return null

    tx = (x / tile-size) .|. 0
    ty = (y / tile-size) .|. 0

    if tx >= grid.cols or ty >= grid.rows
        return null

    dx = x - tx * tile-size - tile-size / 2
    dy = y - ty * tile-size - tile-size / 2

    edge = [N, W, E, S][(dy > dx) * 1 + (dx > -dy) * 2]

    return grid.edge-map[ty][tx][edge]

handler = (f, ev) -->
    x = ev.page-x - canvas.offset-left
    y = ev.page-y - canvas.offset-top
    tile = get-tile-at x, y
    return f tile, ev
