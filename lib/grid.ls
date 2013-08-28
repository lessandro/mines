{unique} = require 'prelude-ls'
{shuffle, srand, rand} = require './util'
{psum} = require './math'
{rotate-edge, edge-list, find-center, square, trapezoids} = require './shape'

[w, h] = [0 0]
edge-map = []
tiles = []

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

gen-grid = !->
    [row, col, edge] = [0, 0, 1]
    order = [to shapes.length - 1]

    while row < h
        next = next-place row, col, edge

        if !edge-map[row][col][edge]
            shuffle order
            found = false

            tiles.push (tile = {col, row, n: tiles.length})

            for i in order
                shape = shapes[i]

                if !has-edge(edge, shape)
                    continue

                if !shape-fits(row, col, shape)
                    continue

                tile.shape = shape
                place-tile tile
                found = true
                break

            if !found
                # replace trapezoid tile with 2 squares
                edge1 = rotate-edge edge
                edge2 = rotate-edge edge1
                other = edge-map[row][col][edge1] or edge-map[row][col][edge2]

                unplace-tile other
                other.shape = square
                other.col = other.col + other.shape.center[0]
                other.row = other.row + other.shape.center[1]
                place-tile other

                tile.shape = square
                place-tile tile

        [row, col, edge] = next

build-graph = !->
    vertex-map = {}

    for tile in tiles
        for vertex in tile.shape.contour
            key = "#{vertex[0] + tile.col},#{vertex[1] + tile.row}"
            if !vertex-map[key]
                vertex-map[key] = []
            vertex-map[key].push tile.n

    for tile in tiles
        neighbors = []
        for vertex in tile.shape.contour
            key = "#{vertex[0] + tile.col},#{vertex[1] + tile.row}"
            for n in vertex-map[key]
                neighbors.push n
        neighbors = unique neighbors
        tile.neighbors = [tiles[n] for n in neighbors when n != tile.n]

export make-grid = (w_, h_, seed) !->
    w := w_
    h := h_

    seed = seed or rand!
    srand seed

    reset-grid!
    gen-grid!
    build-graph!

    return {edge-map, tiles, rows:h, cols:w, seed:seed}
