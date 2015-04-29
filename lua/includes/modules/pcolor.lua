pcolor = pcolor or {}

local tohex     = bit.tohex
local Color     = Color
local tostring  = tostring
local tonumber  = tonumber

function pcolor.ToHex(col)
    return '#' .. tohex(col.r or 255, 2) .. tohex(col.g or 255, 2) .. tohex(col.b or 255, 2)
end

function pcolor.FromHex(hex)
  hex = tostring(hex)
    hex = hex:gsub('#','')
    return Color(tonumber('0x' .. hex:sub(1, 2)), tonumber('0x' .. hex:sub(3, 4)), tonumber('0x' .. hex:sub(5, 6)))
end