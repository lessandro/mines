{last} = require 'prelude-ls'

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
        ctx.lineTo x, y
    ctx.fill!

randn = (n) -> ((Math.random! * 0x7fffffff) .|. 0) %% n

random-color = -> '#' + [(3 + randn 13).to-string 16 for i to 5] * ''

draw-shape = (x, y, scale, shape) ->
    ctx.save!
    ctx.translate x, y
    ctx.scale scale, scale
    ctx.fillStyle = random-color()
    draw-contour shape.contour
    ctx.restore!
