local assert = assert
local setmetatable = setmetatable
local tonumber = tonumber
local type = type
local coroutine = coroutine
local io = io
local awful = require('awful')
local lfs = require('lfs')

module('util.run_once')

-- {{{ Run programm once
local function processwalker()
    local function yieldprocess()
        for dir in lfs.dir('/proc') do
            -- All directories in /proc containing a number, represent a process
            if tonumber(dir) ~= nil then
                local f, err = io.open('/proc/'..dir..'/cmdline')
                if f then
                    local cmdline = f:read('*all')
                    f:close()
                    if cmdline ~= '' then
                        coroutine.yield(cmdline)
                    end
                end
            end
        end
    end
    return coroutine.wrap(yieldprocess)
end

local function run_once(process, cmd)
    assert(type(process) == 'string')
    local regex_killer = {
        ['+']  = '%+', ['-'] = '%-',
        ['*']  = '%*', ['?']  = '%?'
    }

    for p in processwalker() do
        if p:find(process:gsub('[-+?*]', regex_killer)) then
            return
        end
    end
    return awful.util.spawn_with_shell(cmd or process)
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return run_once(...) end })
