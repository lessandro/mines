{apply, last} = require 'prelude-ls'

canvas = document.getElementById 'canvas'
ctx = canvas.getContext '2d'

reset = !->
    canvas.width = window.innerWidth
    canvas.height = window.innerHeight
    ctx.clearRect 0, 0, canvas.width, canvas.height

window.addEventListener 'resize', reset, false
reset!

draw-contour = (contour) ->
    ctx.beginPath!
    (-> ctx.moveTo it[0], it[1]) last contour
    for [x, y] in contour
        ctx.lineTo x + Math.random! / 3, y + Math.random! / 3
    ctx.stroke!

draw-shape = (x, y, scale, shape) ->
    ctx.save!
    ctx.translate x, y
    ctx.scale scale, scale
    ctx.lineWidth = 1.0/scale
    draw-contour shape.contour
    ctx.restore!

steps = (->
    tri2 = rotate-shape rotate-shape triangle
    [
        -> square
        -> concat-shapes it, square
        -> concat-shapes it, triangle
        -> rotate-shape it
        -> concat-shapes it, triangle
        -> rotate-shape it
        -> concat-shapes it, triangle
        -> rotate-shape it
        -> concat-shapes it, tri2
        -> join-shapes it, translate-shape tri2, [1 2]
        -> join-shapes it, translate-shape triangle, [1 2]
    ])()

for step in steps
    crazy = step crazy
    draw-shape 30, 30, 20, crazy
    ctx.translate (crazy.size[0]+1) * 20, 0
