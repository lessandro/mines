{last} = require 'prelude-ls'

canvas = document.getElementById 'canvas'
ctx = canvas.getContext '2d'

tile-size = 30

reset-canvas = !->
    canvas.width = w * tile-size
    canvas.height = h * tile-size

draw-contour = (contour) ->
    ctx.beginPath!
    (-> ctx.moveTo it[0], it[1]) last contour
    for [x, y] in contour
        ctx.lineTo x, y

randn = (n) -> ((Math.random! * 0x7fffffff) .|. 0) %% n

random-color = -> '#' + [(3 + randn 13).to-string 16 for i to 5] * ''

draw-tile = (tile, size) ->
    ctx.save!
    ctx.translate tile.col * size, tile.row * size
    ctx.save!
    ctx.scale size, size
    ctx.lineWidth = 1.0/size
    ctx.fillStyle = '#cccccc'
    if tile.marked
        ctx.fillStyle = 'pink'
    if tile.highlighted
        ctx.fillStyle = 'cyan'
    if tile.exposed
        ctx.fillStyle = 'white'
        if tile.bomb
            ctx.fillStyle = 'pink'
    draw-contour tile.shape.contour
    if !tile.exposed or tile.text
        ctx.fill!
        ctx.stroke!
    ctx.restore!
    if tile.exposed
        ctx.font = "20px arial"
        width = ctx.measureText(tile.text).width
        ctx.fillText tile.text,
            tile.shape.center[0]*size + size/2 - width/2,
            tile.shape.center[1]*size + size/2 + 6
    ctx.restore!

draw-grid = !->
    ctx.clearRect 0, 0, canvas.width, canvas.height
    for tile in tiles
        draw-tile tile, tile-size

    if state == 0
        remaining_div.inner-text = "Bombs left: #bombs"
    else
        remaining_div.inner-text = "Game over!"

get-tile-at = (x, y) ->
    if x < 0 or y < 0
        return null

    tx = (x / tile-size) .|. 0
    ty = (y / tile-size) .|. 0

    if tx >= w or ty >= h
        return null

    dx = x - tx * tile-size - tile-size / 2
    dy = y - ty * tile-size - tile-size / 2

    edge = [N, W, E, S][(dy > dx) * 1 + (dx > -dy) * 2]

    return edge-map[ty][tx][edge]

handler = (f, ev) !-->
    x = ev.client-x - canvas.offset-left
    y = ev.client-y - canvas.offset-top
    tile = get-tile-at x, y
    f tile, ev
