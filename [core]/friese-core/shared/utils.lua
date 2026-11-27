Friese = Friese or {}
function Friese.Debug(...)
    if Friese.Config and Friese.Config.Debug then
        local parts = {}
        for i = 1, select('#', ...) do parts[#parts + 1] = tostring(select(i, ...)) end
        print(('^4[Friese-Core]^7 %s'):format(table.concat(parts, ' ')))
    end
end

function Friese.IsPositiveNumber(value)
    value = tonumber(value)
    return value ~= nil and value > 0 and value == math.floor(value)
end

function Friese.SafeDecode(value, fallback)
    if type(value) ~= 'string' or value == '' then return fallback end
    local ok, decoded = pcall(json.decode, value)
    if ok and type(decoded) == 'table' then return decoded end
    return fallback
end
