{reverse} = require 'prelude-ls'
{bor} = require './util'
{mmap, mrot, mzip, msize, msize2, psum, pmax} = require './math'
{rotate-contour, translate-contour, join-contours} = require './contour'

[NW, SW, SE, NE, C] = [[0 0] [0 1] [1 1] [1 0] [0.5 0.5]]
export edge-list = [N, W, S, E] = [1 2 4 8]

export rotate-edge = (edge) ->
    ((edge .<<. 1) .|. (edge .>>. 3)) .&. 0xf

export rotate-shape = (shape) ->
    size = reverse shape.size
    edges = mmap rotate-edge, mrot shape.edges
    contour = rotate-contour shape.contour, size[1]
    return {size, edges, contour}

export translate-shape = (shape, delta) ->
    size = psum shape.size, delta
    edges = msize2 size, shape.edges
    contour = translate-contour shape.contour, delta
    return {size, edges, contour}

export join-shapes = (shape1, shape2) ->
    size = pmax shape1.size, shape2.size
    edges = mzip (.|.), (msize size, shape1.edges), (msize size, shape2.edges)
    contour = join-contours shape1.contour, shape2.contour
    return {size, edges, contour}

# concat shape2 to the bottom of shape1
export concat-shapes = (shape1, shape2) ->
    join-shapes shape1, (translate-shape shape2, [0, shape1.size[1]])

export find-center = (shape) ->
    for j to shape.size[1] - 1
        for i to shape.size[0] - 1
            if shape.edges[j][i] == bor edge-list
                return [i, j]
    return [0 0]

# some basic shapes

export square =
    size: [1 1]
    edges: [[bor [N, W, S, E]]]
    contour: [NW, SW, SE, NE]

export triangle = # |/
    size: [1 1]
    edges: [[bor [N, W]]]
    contour: [NW, SW, NE]

export triangle2 = #\/
    size: [1 1]
    edges: [[N]]
    contour: [NW, C, NE]

make-trapezoids = ->
    shapes = []

    inverted = rotate-shape rotate-shape rotate-shape triangle
    for t in [triangle, inverted]
        shapes.push (pointy = concat-shapes square, t)
        shapes.push (pointy = rotate-shape pointy)
        shapes.push (pointy = rotate-shape pointy)
        shapes.push (pointy = rotate-shape pointy)

    return shapes

export trapezoids = make-trapezoids!
