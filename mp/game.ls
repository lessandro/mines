{take, sum, tail, filter, map, all} = require 'prelude-ls'
{srand, rand, shuffle} = require '../lib/util'
{make-grid} = require '../lib/grid'
{place-bombs, expose-tile} = require '../lib/mines'

export class Game
    restart: !->
        @grid = make-grid 20, 16
        @turn = (@restarts++ %% 2)
        @scores = [0, 0]
        @winner = null
        @total-bombs = 51

        srand!
        place-bombs @grid, @total-bombs

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

        @players.push obj

        return @players.length-1

    del-player: (player) !->
        if player < 2
            @players[player] = null
        else
            @players.splice player, 1

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

        if tile.bomb
            tile.exposed = true
            tile.text = "AB"[@turn]
            @scores[@turn] += 1
            if @scores[@turn] > @total-bombs / 2
                @winner = @turn
                @turn = -1
                return false

            return false

        expose-tile tile

        return true

    click-tile: (player, n) !->
        if player != @turn
            return false

        tile = @grid.tiles[n]
        if tile.exposed
            return false

        if @expose tile
            @turn = (@turn + 1) %% 2

        return true

    player-restart: (player) !->
        @winner = null
        @scores[player] = -1

        if all (== -1), @scores
            @restart!
            return true

        return false