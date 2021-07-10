--
-- Author: HyagoGow
-- A common Rectangle class
--
local class = require("middleclass")
local Vector2 = require("Vector2")

local Rect = class('Rect')

function Rect:initialize(center, size)
    self.center = center or Vector2:new()
    self.size = size or Vector2:new(1, 1)
end

function Rect:from(x, y, width, height)
    local topLeft = Vector2:new(x, y)
    local size = Vector2:new(width, height)
    local center = topLeft + size * 0.5

    return Rect:new(center, size)
end

function Rect:log()
    console.log(tostring(self))
end

function Rect:draw(lineColor, backgroundColor)
    local topLeft = self:getTopLeft()
    gui.drawRectangle(topLeft.x, topLeft.y, self.size.x, self.size.y, lineColor, backgroundColor)
end

function Rect:move(position)
    self.center = self.center + position
end

function Rect:expand(size)
    self.size = self.size + size
end

function Rect:getHalfSize()
    return self.size * 0.5
end

function Rect:getTopLeft()
    return self.center - self:getHalfSize()
end

function Rect:getTopRight()
    local halfSize = self:getHalfSize()
    halfSize.y = -halfSize.y
    return self.center + halfSize
end

function Rect:getBottomLeft()
    local halfSize = self:getHalfSize()
    halfSize.y = -halfSize.y
    return self.center - halfSize
end

function Rect:getBottomRight()
    return self.center + self:getHalfSize()
end

function Rect:isInside(position)
    local topLeft = self:getTopLeft()
    local bottomRight = self:getBottomRight()
    local insideFromLeft = position.x > topLeft.x and position.y > topLeft.y
    local insideFromRight = position.x < bottomRight.x and position.y < bottomRight.y

    return insideFromLeft and insideFromRight
end

function Rect:__tostring()
    return string.format("Center: %s. Size: %s", tostring(self.center), tostring(self.size))
end

function Rect:__eq(other)
    return self.center == other.center and self.size == other.size
end

function Rect:__add(other)
    return Rect:new(self.center + other.center, self.size + other.size)
end

function Rect:__sub(other)
    return Rect:new(self.center - other.center, self.size - other.size)
end

function Rect:__mul(x)
    return Rect:new(self.center * x, self.size * x)
end

return Rect
