{foldr} = require 'prelude-ls'

# list equality
export eq = (a, b) -> a >= b and a <= b

# list binary or
export bor = foldr (.|.), 0

state = null

export srand = (n) ->
    if n
        state := n
    else
        state := (Math.random! * 0x7fffffff) .|. 0

srand!

export rand = (n) -> state := (69069 * state + 362437) .&. 0x7fffffff

export randn = (n) -> rand! %% n

export shuffle = (a) !->
    for i from a.length - 1 to 1 by -1
        j = randn (i + 1)
        [a[j], a[i]] = [a[i], a[j]]
