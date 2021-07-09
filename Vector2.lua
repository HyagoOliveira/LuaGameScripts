--
-- Author: HyagoGow
-- A common Vector2 class
--
local class = require("middleclass")
local Vector2 = class('Vector2')

function Vector2:initialize(x, y)
    self.x = x or 0
    self.y = y or 0
end

function Vector2:log()
    console.log(tostring(self))
end

function Vector2:logHex()
    local text = string.format("(%s, %s)", bizstring.hex(self.x), bizstring.hex(self.y))
    console.log(text)
end

function Vector2:printScreenSpace(x, y, label, forecolor, anchor)
    local text = string.format("%s: %s", label, tostring(self))
    -- Draws on emulator screen space (like all draw functions).
    gui.drawText(x, y, text, forecolor, anchor)
end

function Vector2:print(x, y, label, forecolor, anchor)
    local text = string.format("%s: %s", label, tostring(self))
    -- Draws on the screen at the given coordinates.
    gui.text(x, y, text, forecolor, anchor)
end

function Vector2:draw(color, size, surfacename)
    size = size or 2
    color = color or "red"
    gui.drawAxis(self.x, self.y, size, color, surfacename)
end

function Vector2:hasXValue()
    return math.abs(self.x) > 0
end

function Vector2:hasYValue()
    return math.abs(self.y) > 0
end

function Vector2:hasValue()
    return self:hasXValue() or self:hasYValue()
end

function Vector2:scale(i)
    return Vector2:new(self.x * i, self.y * i)
end

function Vector2:__tostring()
    return string.format("(%.2f, %.2f)", self.x, self.y)
end

function Vector2:__eq(other)
    return self.x == other.x and self.y == other.y
end

function Vector2:__add(other)
    return Vector2:new(self.x + other.x, self.y + other.y)
end

function Vector2:__sub(other)
    return Vector2:new(self.x - other.x, self.y - other.y)
end

function Vector2:__mul(other)
    if type(other) == 'number' then
        return self:scale(other)
    end

    return Vector2:new(self.x * other.x, self.y * other.y)
end

function Vector2:__div(other)
    if type(other) == 'number' then
        return Vector2:new(self.x / other, self.y / other)
    end

    return Vector2:new(self.x / other.x, self.y / other.y)
end

return Vector2
