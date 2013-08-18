{map, foldr, max, take, drop, slice, reverse} = require 'prelude-ls'

[NW, SW, SE, NE, C] = [[0 0] [0 1] [1 1] [1 0] [0.5, 0.5]]
edge-list = [N, W, S, E] = [1 2 4 8]

# list equality
eq = (a, b) -> a >= b and a <= b

# list binary or
bor = foldr (.|.), 0

# matrix rotate, ccw
mrot = (m) ->
    cols = m[0].length
    rows = m.length
    for i to cols - 1
        for j to rows - 1
            m[j][cols - i - 1]

# matrix zip-with
mzip = (f, m1, m2) ->
    rows = m1.length
    cols = m1[0].length
    for i to rows - 1
        for j to cols - 1
            f m1[i][j], m2[i][j]

# matrix map
mmap = (f, m) -> map (map f), m

# matrix resize, fills bottom/right with zeroes
msize = ([cols, rows], m) ->
    m1 = [row ++ [0 for i from row.length to cols - 1 by 1] for row in m]
    m1 ++= [[0] * cols for i from m.length to rows - 1 by 1]
    return m1

# matrix resize, fills top/left with zeroes
msize2 = ([cols, rows], m) ->
    m1 = [[0] * cols for i from m.length to rows - 1 by 1]
    m1 ++= [[0 for i from row.length to cols - 1 by 1] ++ row for row in m]
    return m1

# point sum/translate
psum = ([x1, y1], [x2, y2]) --> [x1 + x2, y1 + y2]

# point max
pmax = ([x1, y1], [x2, y2]) -> [(max x1, x2), (max y1, y2)]

# point rotate, ccw
prot = ([x, y]) -> [y, -x]

rotate-edge = (edge) -> ((edge .<<. 1) .|. (edge .>>. 3)) .&. 0xf

rotate-shape = (shape) ->
    size = reverse shape.size
    size: size
    edges: mmap rotate-edge, mrot shape.edges
    contour: map (psum [0, size[1]]) . prot, shape.contour

translate-contour = (contour, point) -> map (psum point), contour

find-splice-point = (contour1, contour2) ->
    point = null
    for i from 0 to contour1.length - 1
        for j from 0 to contour2.length - 1
            if contour1[i] `eq` contour2[j]
                # found a shared vetex
                point = [i, j]
                # prefer an edge match
                prev = (i - 1) %% contour1.length
                next = (j + 1) %% contour2.length
                if contour1[prev] `eq` contour2[next]
                    return point
    return point

# O(n^2), but can be made O(n)
trim-contour = (contour) !->
    i = 0
    while i < contour.length
        prev = (i - 1) %% contour.length
        next = (i + 1) %% contour.length
        if contour[prev] `eq` contour[next]
            contour.splice(i %% contour.length, 1)
            contour.splice(i %% contour.length, 1)
            i--
        else
            i++

join-contours = (contour1, contour2) ->
    splice-point = find-splice-point contour1, contour2
    if splice-point == null
        throw "contours dont share a vertex"

    [i, j] = splice-point

    contour = take i, contour1
    contour ++= drop j, contour2
    contour ++= take j, contour2
    contour ++= drop i, contour1

    trim-contour contour

    return contour

join-shapes = (shape1, shape2) ->
    size = pmax shape1.size, shape2.size
    size: size
    edges: mzip (.|.), (msize size, shape1.edges), (msize size, shape2.edges)
    contour: join-contours shape1.contour, shape2.contour

translate-shape = (shape, delta) ->
    size = psum shape.size, delta
    size: size
    edges: msize2 size, shape.edges
    contour: translate-contour shape.contour, delta

# add a new shape on the bottom
concat-shapes = (shape1, shape2) ->
    join-shapes shape1, (translate-shape shape2, [0, shape1.size[1]])

# some basic shapes

square =
    size: [1, 1]
    edges: [[bor [N, W, S, E]]]
    contour: [NW, SW, SE, NE]

triangle = # |/
    size: [1, 1]
    edges: [[bor [N, W]]]
    contour: [NW, SW, NE]

triangle2 = #\/
    size: [1, 1]
    edges: [[N]]
    contour: [NW, C, NE]

# square + pointy rectangles

shapes = []

find-center = (shape) ->
    for j to shape.size[1] - 1
        for i to shape.size[0] - 1
            if shape.edges[j][i] == 15
                return [i, j]

make-shapes = !->
    for i to 4
        shapes.push square

    inverted = rotate-shape rotate-shape rotate-shape triangle
    for t in [triangle, inverted]
        shapes.push (pointy = concat-shapes square, t)
        shapes.push (pointy = rotate-shape pointy)
        shapes.push (pointy = rotate-shape pointy)
        shapes.push (pointy = rotate-shape pointy)

    for shape in shapes
        shape.center = find-center shape

make-shapes!
