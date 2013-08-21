{unique, filter} = require 'prelude-ls'
{shuffle} = require './util'
{psum} = require './math'
{edge-list, find-center, square, trapezoids} = require './shape'

[w, h] = [0 0]
edge-map = []
tiles = []

max-attempts = 10
max-iterations = 10000
iterations = 0

make-shapes = ->
    shapes = trapezoids ++ [square] * 5
    for shape in shapes
        shape.center = find-center shape
    return shapes

shapes = make-shapes!

reset-grid = !->
    edge-map := [[[] for i to w - 1] for j to h - 1]
    tiles := []

next-place = (row, col, edge) ->
    edge = edge .<<. 1
    if edge == 16
        edge = 1
        col = col + 1
        if col == w
            col = 0
            row = row + 1
    return [row, col, edge]

has-edge = (edge, shape) -> shape.edges[0][0] .&. edge

shape-fits = (row, col, shape) ->
    [sw, sh] = shape.size

    if row + sh > h or col + sw > w
        return false

    for j to sh - 1
        for i to sw - 1
            for edge in edge-list
                if shape.edges[j][i] .&. edge
                    if edge-map[row + j][col + i][edge]
                        return false

    return true

place-tile = (tile) !->
    [sw, sh] = tile.shape.size

    for j to sh - 1
        for i to sw - 1
            for edge in edge-list
                if tile.shape.edges[j][i] .&. edge
                    edge-map[tile.row + j][tile.col + i][edge] = tile

unplace-tile = (tile) !->
    [sw, sh] = tile.shape.size

    for j to sh - 1
        for i to sw - 1
            for edge in edge-list
                if tile.shape.edges[j][i] .&. edge
                    delete edge-map[tile.row + j][tile.col + i][edge]

random-order = ->
    order = [to shapes.length - 1]
    shuffle order
    return order

try-place-tile = (row, col, edge) ->
    if row == h
        return true

    iterations := iterations + 1
    if iterations == max-iterations
        throw new Error 'maximum iteration count reached'

    next = next-place row, col, edge

    if edge-map[row][col][edge]
        return try-place-tile.apply null, next

    order = random-order!

    for i in order
        shape = shapes[i]

        if !has-edge(edge, shape)
            continue

        if !shape-fits(row, col, shape)
            continue

        tile =
            col: col,
            row: row,
            shape: shape,
            n: tiles.length

        tiles.push tile
        place-tile tile

        if try-place-tile.apply null, next
            return true

        unplace-tile tile
        tiles.pop!

    return false

force-place-tile = (row, col, edge) !->
    while row < h
        next = next-place row, col, edge

        if !edge-map[row][col][edge]
            order = random-order!

            for i in order
                shape = shapes[i]

                if !has-edge(edge, shape)
                    continue

                if !shape-fits(row, col, shape)
                    continue

                tile =
                    col: col,
                    row: row,
                    shape: shape,
                    n: tiles.length

                tiles.push tile
                place-tile tile

        [row, col, edge] = next

build-graph = !->
    vertex-map = {}

    for tile in tiles
        for vertex in tile.shape.contour
            key = (psum vertex, [tile.col, tile.row]).to-string!
            if !vertex-map[key]
                vertex-map[key] = []
            vertex-map[key].push tile.n

    for tile in tiles
        neighbors = []
        for vertex in tile.shape.contour
            key = (psum vertex, [tile.col, tile.row]).to-string!
            neighbors ++= vertex-map[key]

        neighbors = filter (!= tile.n), unique neighbors
        tile.neighbors = [tiles[n] for n in neighbors]

export make-grid = (w_, h_) !->
    w := w_
    h := h_

    for i to max-attempts
        reset-grid!
        try
            iterations := 0
            try-place-tile 0, 0, 1
            break
        catch

        if i == max-attempts
            reset-grid!
            force-place-tile 0, 0, 1

    build-graph!

    return {edge-map, tiles, rows:h, cols:w}
