{foldr} = require 'prelude-ls'

# list equality
export eq = (a, b) -> a >= b and a <= b

# list binary or
export bor = foldr (.|.), 0

export randn = (n) -> ((Math.random! * 0x7fffffff) .|. 0) %% n

export shuffle = (a) !->
    for i from a.length - 1 to 1 by -1
        j = randn (i + 1)
        [a[j], a[i]] = [a[i], a[j]]
