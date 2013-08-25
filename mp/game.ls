{take, sum, tail, filter, map, all} = require 'prelude-ls'
{srand, rand, shuffle} = require '../lib/util'
{make-grid} = require '../lib/grid'

export class Game
    assign-bombs: !->
        pos = [0 to @grid.tiles.length-1]
        shuffle pos
        pos = take @total-bombs, pos
        for n in pos
            @grid.tiles[n].bomb = 1

        for tile in @grid.tiles
            tile.exposed = false

            if tile.bomb
                tile.text = '*'
                continue

            n = [1 for neighbor in tile.neighbors when neighbor.bomb].length
            tile.text = if n == 0 then '' else n.to-string!

    restart: !->
        @grid = make-grid 20, 16
        @turn = (@restarts++ %% @players.length)
        @scores = [0, 0]
        @winner = null
        @total-bombs = 51

        srand!
        @assign-bombs!

    (name) ->
        @name = name or rand! .to-string 36
        @players = [null, null]
        @restarts = 0
        @restart!

    add-player: (obj) !->
        for n from 0 to 1
            if @players[n] == null
                @players[n] = obj
                return n

        return null

    del-player: (player) !->
        @players[player] = null
        return @num-players! == 0

    num-players: ->
        (filter (!= null), @players).length

    serialize-tile = (tile) ->
        if tile.exposed then tile.text else null

    serialize: ->
        JSON.stringify do
            name: @name
            seed: @grid.seed
            rows: @grid.rows
            cols: @grid.cols
            turn: @turn
            scores: @scores
            bombs: @total-bombs
            winner: @winner
            players: map (!= null), @players
            tiles: map serialize-tile, @grid.tiles

    expose: (tile) ->
        if tile.exposed
            return false

        tile.exposed = true

        if tile.bomb
            tile.text = "AB"[@turn]
            @scores[@turn] += 1
            if @scores[@turn] > @total-bombs / 2
                @winner = @turn
                @turn = -1
                return false

            return false

        if tile.text == ''
            for neighbor in tile.neighbors
                @expose neighbor

        return true

    click-tile: (player, n) !->
        if player != @turn
            return false

        tile = @grid.tiles[n]
        if tile.exposed
            return false

        if @expose tile
            @turn = (@turn + 1) %% @players.length

        return true

    player-restart: (player) !->
        @winner = null
        @scores[player] = -1

        if all (== -1), @scores
            @restart!
            return true

        return false