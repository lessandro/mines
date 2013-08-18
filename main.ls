{last} = require 'prelude-ls'

canvas = document.getElementById 'canvas'
ctx = canvas.getContext '2d'

reset-canvas = !->
    canvas.width = window.innerWidth
    canvas.height = window.innerHeight

#window.addEventListener 'resize', reset-canvas, false
reset-canvas!

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
    ctx.scale size, size
    ctx.lineWidth = 1.0/size
    ctx.fillStyle = tile.color
    draw-contour tile.shape.contour
    if tile.selected
        ctx.fill!
    ctx.stroke!
    ctx.restore!
