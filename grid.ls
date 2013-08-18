{apply, unique, filter} = require 'prelude-ls'

[w, h] = [16 16]
edge-map = []
tiles = []
iterations = 0
size = 40

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
            color: random-color!,
            selected: 0,
            n: tiles.length
            center: [0, 0]

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

make-grid = !->
    reset-grid!
    try
        try-place-tile 0, 0, 1
    catch
        window.set-timeout make-grid, 10
        return
    build-graph!
    draw-grid!

draw-grid = !->
    for tile in tiles
        draw-tile tile, size

make-grid!

selected = null

get-tile-at = (x, y) ->
    if x < 0 or y < 0
        return null

    tx = (x / size) .|. 0
    ty = (y / size) .|. 0

    if tx >= w or ty >= h
        return null

    dx = x - tx * size - size / 2
    dy = y - ty * size - size / 2

    edge = [N, W, E, S][(dy > dx) * 1 + (dx > -dy) * 2]

    return edge-map[ty][tx][edge]

move = !->
    tile = get-tile-at it.clientX, it.clientY

    if !tile
        return

    if tile != selected
        if selected
            selected.selected = 0
            for neighbor in selected.neighbors
                neighbor.selected = 0

        tile.selected = 1
        for neighbor in tile.neighbors
            neighbor.selected = 2

        selected := tile
        draw-grid!

window.addEventListener 'mousemove', move, false
