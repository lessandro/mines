{map, take, drop} = require 'prelude-ls'
{psum, prot} = require './math'
{eq} = require './util'

export translate-contour = (contour, point) -->
    map (psum point), contour

export rotate-contour = (contour, height) ->
    translate-contour (map prot, contour), [0, height]

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

export join-contours = (contour1, contour2) ->
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
