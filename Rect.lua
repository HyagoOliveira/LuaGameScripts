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

function Rect:fromLeftBottom(leftBottom, size)
    local center = leftBottom + size * 0.5
    return Rect:new(center, size)
end

function Rect:log()
    console.log(tostring(self))
end

function Rect:draw(lineColor, backgroundColor)
    local bottomLeft = self:getBottomLeft()
    gui.drawRectangle(bottomLeft.x, bottomLeft.y, self.size.x, self.size.y, lineColor, backgroundColor)
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

function Rect:getTopRight()
    return self.center + self:getHalfSize()
end

function Rect:getBottomLeft()
    return self.center - self:getHalfSize()
end

function Rect:isInside(position)
    local bottomLeft = self:getBottomLeft()
    local topRight = self:getTopRight()
    local insideFromLeft = position.x > bottomLeft.x and position.y > bottomLeft.y
    local insideFromRight = position.x < topRight.x and position.y < topRight.y
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
