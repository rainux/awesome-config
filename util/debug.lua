local setmetatable = setmetatable
local naughty = require('naughty')

module('util.debug')

local function debug(text, timeout, width)
    timeout = timeout or 5
    width = width or 480
    naughty.notify({ text = text, timeout = timeout, width = width })
end

setmetatable(_M, { __call = function(_, ...) return debug(...) end })
