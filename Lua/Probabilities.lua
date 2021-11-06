local random = math.random

local DIFFICULTY = -1

local distribution = {
    MIN_CODES = 1,
    MAX_CODES = 7
}

function distribution.NumCodes()
    local chances = { -- this is very dumb
        1
    }
    return chances[random(1, #chances)]
end

local function VaryByDifficulty(Settings)
    local difficulty = -1
    for i = 1, #Settings do
        if DIFFICULTY == difficulty then
            return Settings[i]
        end
        difficulty = difficulty + 1
    end
    return Settings[1]
end

function distribution.ShortCodeDelay()
    return VaryByDifficulty({
        -random(30, 45),
        -random(60*2, 60*5) -- 2 to 5s
    })
end

function distribution.LongCodeDelay()
    return VaryByDifficulty({
        -random(30, 45),
        -random(60*30, 60*45) -- 30 to 45s
    })
end

function distribution.TargetTimer()
    return VaryByDifficulty({
        60*5,
        1800 + random(-180, 180) -- 30 +- 3 seconds
    })
end

return distribution
