{apply, unique, filter} = require 'prelude-ls'

[w, h] = [20 16]
edge-map = []
tiles = []
iterations = 0

reset-grid = ->
    edge-map := [[[] for i to w - 1] for j to h - 1]
    tiles := []
    graph = []
    iterations := 10000

shuffle = (a) !->
    for i from a.length - 1 to 1 by -1
        j = randn (i + 1)
        [a[j], a[i]] = [a[i], a[j]]

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

try-place-tile = (row, col, edge) ->
    if row == h
        return true

    iterations := iterations - 1
    if iterations == 0
        throw 'err'

    next = next-place row, col, edge

    if edge-map[row][col][edge]
        return apply try-place-tile, next

    order = [to shapes.length - 1]
    shuffle order

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

        if apply try-place-tile, next
            return true

        unplace-tile tile
        tiles.pop!

    return false

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

make-grid = (cb) !->
    reset-grid!
    try
        try-place-tile 0, 0, 1
    catch
        window.set-timeout (-> make-grid cb), 10
        return

    build-graph!
    cb!
