{map, max} = require 'prelude-ls'

# matrix rotate, ccw
export mrot = (m) ->
    cols = m[0].length
    rows = m.length
    for i to cols - 1
        for j to rows - 1
            m[j][cols - i - 1]

# matrix zip-with
export mzip = (f, m1, m2) ->
    rows = m1.length
    cols = m1[0].length
    for i to rows - 1
        for j to cols - 1
            f m1[i][j], m2[i][j]

# matrix map
export mmap = (f, m) -> map (map f), m

# matrix resize, fills bottom/right with zeroes
export msize = ([cols, rows], m) ->
    m1 = [row ++ [0 for i from row.length to cols - 1 by 1] for row in m]
    m1 ++= [[0] * cols for i from m.length to rows - 1 by 1]
    return m1

# matrix resize, fills top/left with zeroes
export msize2 = ([cols, rows], m) ->
    m1 = [[0] * cols for i from m.length to rows - 1 by 1]
    m1 ++= [[0 for i from row.length to cols - 1 by 1] ++ row for row in m]
    return m1

# point sum/translate
export psum = ([x1, y1], [x2, y2]) --> [x1 + x2, y1 + y2]

# point max
export pmax = ([x1, y1], [x2, y2]) -> [(max x1, x2), (max y1, y2)]

# point rotate, ccw
export prot = ([x, y]) -> [y, -x]
