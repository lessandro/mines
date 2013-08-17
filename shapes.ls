{map, foldr, max, take, drop, slice, reverse} = require 'prelude-ls'

[NW, SW, SE, NE] = [[0 0] [0 1] [1 1] [1 0]]
[N, W, S, E] = [1 2 4 8]

# list equality
aeq = (a, b) -> a >= b and a <= b

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
msize = ([rows, cols], m) ->
    m1 = [row ++ [0 for i from row.length to cols - 1 by 1] for row in m]
    m1 ++= [[0] * cols for i from m.length to rows - 1 by 1]
    return m1

# matrix resize, fills top/left with zeroes
msize2 = ([rows, cols], m) ->
    m1 = [[0] * cols for i from m.length to rows - 1 by 1]
    m1 ++= [[0 for i from row.length to cols - 1 by 1] ++ row for row in m]
    return m1

# point sum/translate
psum = ([x1, y1], [x2, y2]) --> [x1 + x2, y1 + y2]

# point max
pmax = ([x1, y1], [x2, y2]) -> [(max x1, x2), (max y1, y2)]

# point rotate, ccw
prot = ([x, y]) -> [y, -x]

square =
    size: [1, 1]
    edges: [[bor [N, W, S, E]]]
    contour: [NW, SW, SE, NE, NW]

triangle = # |/
    size: [1, 1]
    edges: [[bor [N, W]]]
    contour: [NW, SW, NE, NW]

rotate-edge = (edge) -> ((edge .<<. 1) .|. (edge .>>. 3)) .&. 0xf

rotate-shape = (shape) ->
    size = reverse shape.size
    size: size
    edges: mmap rotate-edge, mrot shape.edges
    contour: map (psum [0, size[1]]) . prot, shape.contour

translate-contour = (contour, point) -> map (psum point), contour

find-splice-point = (contour1, contour2) ->
    for i from 0 to contour1.length-2
        for j from 0 to contour2.length-2
            if aeq contour2[j], contour1[i + 1]
                if aeq contour2[j+1], contour1[i]
                    return [i, j]

    return null

join-contours = (contour1, contour2) ->
    splice-point = find-splice-point contour1, contour2
    if not splice-point
        throw "contours dont share an edge"

    [i, j] = splice-point

    #   a b c d e a        i = 2
    # + z w d c x z        j = 2
    # = a b c x z w d e a

    contour = take i, contour1          # a b
    contour ++= drop j + 1, contour2    # c x z
    contour ++= slice 1, j, contour2    # w
    contour ++= drop i + 1, contour1    # d e a

    return contour

join-shape = (shape1, shape2) ->
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
concat-shape = (shape1, shape2) ->
    join-shape shape1, (translate-shape shape2, [0, shape1.size[1]])
