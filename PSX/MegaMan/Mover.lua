local Rect = require "Rect"
--
-- Author: HyagoGow
-- A Mover class used to freealy move a GameObject.
--
local Vector2 = require("Vector2")
local class = require("middleclass")
local KeyboardInput = require("KeyboardInput")

local Mover = class('Mover')

function Mover:initialize(gameObject, speed, buttons)
    self.speed = speed or 10
    self.buttons = buttons
    self.enabled = false
    self.position = Vector2:new()
    self.velocity = Vector2:new()
    self.gameObject = gameObject
    self.inputTextPos = Vector2:new(200, 430)
    self.inputText = string.format(
        "Use %s, %s, %s and %s to move the %s.", self.buttons.left, self.buttons.up, self.buttons.down,
        self.buttons.right, tostring(gameObject.name)
    )

    local function disable()
        self.enabled = false
    end
    event.onloadstate(disable)
end

function Mover:update()
    if self.enabled then
        self:updatePosition()
        self:drawInputInstructions()
    end
end

function Mover:updatePosition()
    self.velocity = self:getInputDirection() * self.speed
    self.position = self.position + self.velocity

    if self.position.x < 0 then
        self.position.x = 0
    end
    if self.position.y < 0 then
        self.position.y = 0
    end

    self.gameObject.position:write(self.position)
end

function Mover:drawInputInstructions()
    gui.drawText(self.inputTextPos.x, self.inputTextPos.y, self.inputText)
end

function Mover:getInputDirection()
    local x = KeyboardInput.INSTANCE:getAxis(self.buttons.right, self.buttons.left)
    local y = KeyboardInput.INSTANCE:getAxis(self.buttons.down, self.buttons.up)
    return Vector2:new(x, y)
end

function Mover:drawToggleButton(x, y, width)
    local toogle = KeyboardInput.INSTANCE:isToggleButtonDown("Free Movement", self.enabled, x, y, width)
    if toogle then
        self:toggle()
    end
end

function Mover:toggle()
    self.enabled = not self.enabled
    self.position = self.gameObject.position.realValue
end

return Mover
