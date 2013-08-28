{filter, take} = require 'prelude-ls'
{shuffle} = require '../lib/util'

bomb-symbol = (->
    # nodejs
    if typeof module !== 'undefined'
        return "@"

    # browser
    mac = window.navigator.app-version.index-of "Mac" != -1
    chrome = !!window.chrome

    if mac and chrome then "@" else "\uD83D\uDCA3"
)!

export place-bombs = (grid, total-bombs, except) !->
    pos = filter (!= except), [0 to grid.tiles.length-1]
    shuffle pos
    pos = take total-bombs, pos

    for n in pos
        grid.tiles[n].bomb = 1

    for tile in grid.tiles
        tile.exposed = false

        if tile.bomb
            tile.text = bomb-symbol
            continue

        n = [1 for neighbor in tile.neighbors when neighbor.bomb].length
        tile.num = n
        tile.text = if n > 0 then n.to-string! else ''
