pcolor = pcolor or { }
local rshift, lshift, bor, band
do
  local _obj_0 = bit
  rshift, lshift, bor, band = _obj_0.rshift, _obj_0.lshift, _obj_0.bor, _obj_0.band
end
local max, min, floor, abs
do
  local _obj_0 = math
  max, min, floor, abs = _obj_0.max, _obj_0.min, _obj_0.floor, _obj_0.abs
end
local Color = Color
pcolor.ToHex = function(col)
  return string.format('#%02X%02X%02X', col.r, col.g, col.b)
end
pcolor.FromHex = function(hex)
  local r, g, b = string.match(hex, '#(..)(..)(..)')
  return Color(tonumber(r, 16), tonumber(g, 16), tonumber(b, 16))
end
pcolor.EncodeArgb = function(col)
  return ((col.a * 0x100 + col.r) * 0x100 + col.g) * 0x100 + col.b
end
pcolor.EncodeRgb = function(col)
  return (col.r * 0x100 + col.g) * 0x100 + col.b
end
pcolor.DecodeArgb = function(num)
  local b = band(num, 0xFF)
  local g = band(rshift(num, 8), 0xFF)
  local r = band(rshift(num, 16), 0xFF)
  local a = band(rshift(num, 24), 0xFF)
  return Color(r, g, b, a)
end
pcolor.DecodeRgb = function(num)
  local b = band(num, 0xFF)
  local g = band(rshift(num, 8), 0xFF)
  local r = band(rshift(num, 16), 0xFF)
  return Color(r, g, b, a)
end
pcolor.LerpCopy = function(frac1, c1, c2)
  local frac2 = 1 - frac1
  return Color(c1.r * frac1 + c2.r * frac2, c1.g * frac1 + c2.g * frac2, c1.b * frac1 + c2.b * frac2, c1.a * frac1 + c2.a * frac2)
end
pcolor.LerpEdit = function(frac1, c1, c2)
  local frac2 = 1 - frac1
  c1.r = c1.r * frac1 + c2.r * frac2
  c1.g = c1.g * frac1 + c2.g * frac2
  c1.b = c1.b * frac1 + c2.b * frac2
  c1.a = c1.a * frac1 + c2.a * frac2
  return c1
end
pcolor.RgbToHsv = function(r, g, b)
  if type(r) == 'table' then
    r, g, b = r.r, r.g, r.b
  end
  min = min(r, min(g, b))
  max = max(r, max(g, b))
  local h, s, v
  v = max
  local delta = max - min
  if max ~= 0 then
    s = delta / max
  else
    s = 0
    h = -1
    return h, s, v
  end
  if r == max then
    h = (g - b) / delta
  elseif g == max then
    h = 2 + (b - r) / delta
  else
    h = 4 + (r - g) / delta
  end
  h = h * 60
  if h < 0 then
    h = h + 360
  end
  return h, s, v
end
pcolor.HsvToRgb = function(h, s, v)
  if s == 0 then
    return v, v, v
  end
  local i = floor(h)
  local f = h - i
  local p = v * (1 - s)
  local q = v * (1 - s * f)
  local t = v * (1 - s * (1 - f))
  local _exp_0 = i
  if 0 == _exp_0 then
    return v, t, p
  elseif 1 == _exp_0 then
    return q, v, p
  elseif 2 == _exp_0 then
    return p, v, t
  elseif 3 == _exp_0 then
    return p, q, v
  elseif 4 == _exp_0 then
    return t, p, v
  else
    return v, p, q
  end
end
