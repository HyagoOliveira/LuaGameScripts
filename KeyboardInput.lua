--
-- Author: HyagoGow
-- A Keyboard Input reader class.
--
local Vector2 = require("Vector2")
local class = require("middleclass")

local KeyboardInput = class('KeyboardInput') -- Creating the KeyboardInput class.

KeyboardInput.static.BUTTON = {
    lineColor = 0xFF6C757D,
    normalBackgroundColor = 0xFF6C757D,
    selectBackgroundColor = 0xFF343A40,
    font = {
        backcolor = "black",
        fontsize = 12,
        fontfamily = "Cambria",
        fontstyle = "Normal"
    },
    toggle = {
        normal = "white",
        select = "violet"
    }
}

function KeyboardInput:initialize()
    self.currentKeys = {}
    self.previousKeys = {}
    self.currentMouse = {}
    self.previousMouse = {}

    KeyboardInput.static.INSTANCE = self

    self:update()
end

function KeyboardInput:update()
    self.previousKeys = self.currentKeys
    self.previousMouse = self.currentMouse

    self.currentKeys = input.get()
    self.currentMouse = input.getmouse()
end

function KeyboardInput:isPreviousKey(key)
    return self.previousKeys[key] or false
end

function KeyboardInput:isKey(key)
    return self.currentKeys[key] or false
end

function KeyboardInput:isKeyDown(key)
    return not self:isPreviousKey(key) and self:isKey(key)
end

function KeyboardInput:isMouseLeftButton()
    return self.currentMouse["Left"] or false
end

function KeyboardInput:isMouseRightButton()
    return self.currentMouse["Right"] or false
end

function KeyboardInput:isMouseLeftButtonDown()
    return not self.previousMouse["Left"] and self:isMouseLeftButton()
end

function KeyboardInput:isMouseRightButtonDown()
    return not self.previousMouse["Right"] and self:isMouseRightButton()
end

function KeyboardInput:isMousePositionOverRect(rect)
    return rect:isInside(self:getMousePosition())
end

function KeyboardInput:isButtonDown(area, text, color)
    local textPos = area:getTopLeft() + Vector2:new(1, 1)
    local isMouseOver = self:isMousePositionOverRect(area)
    local backgroundColor = KeyboardInput.BUTTON.normalBackgroundColor

    if isMouseOver then
        backgroundColor = KeyboardInput.BUTTON.selectBackgroundColor
    end

    area:draw(KeyboardInput.BUTTON.lineColor, backgroundColor)
    gui.drawText(textPos.x, textPos.y, text, color, KeyboardInput.BUTTON.font.backcolor,
        KeyboardInput.BUTTON.font.fontsize, KeyboardInput.BUTTON.font.fontfamily, KeyboardInput.BUTTON.font.fontstyle)

    return isMouseOver and self:isMouseLeftButtonDown()
end

function KeyboardInput:isToggleButtonDown(area, text, enabled)
    local color = KeyboardInput.BUTTON.toggle.normal
    if enabled then
        color = KeyboardInput.BUTTON.toggle.select
    end

    return self:isButtonDown(area, text, color)
end

function KeyboardInput:getMousePosition()
    return Vector2:new(self.currentMouse["X"], self.currentMouse["Y"])
end

function KeyboardInput:getAxis(positive, negative)
    if self:isKey(positive) then
        return 1.0
    elseif self:isKey(negative) then
        return -1.0
    end
    return 0.0
end

return KeyboardInput
