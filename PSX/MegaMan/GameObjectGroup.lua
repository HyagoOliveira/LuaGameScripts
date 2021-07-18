--
-- Author: HyagoGow
-- A GameObjectGroup class for Mega Man games from PSOne.
-- This class will update a group of GameObjects.
--
local Rect = require("Rect")
local class = require("middleclass")
local GameObject = require("GameObject")
local MemoryAddress = require("MemoryAddress")
local KeyboardInput = require("KeyboardInput")

local GameObjectGroup = class('GameObjectGroup') -- Creating the GameObjectGroup class.

function GameObjectGroup:initialize(name, address, showProperties)
    self.name = name
    self.address = address
    self.showProperties = showProperties or false
end

function GameObjectGroup:draw()
    for i = 0, self.address.max - 1 do
        local current = self.address.base + i * self.address.blockSize
        local isEnabled = MemoryAddress.READ["Bool"](current)
        if isEnabled then
            local name = string.format("%s %s", self.name, i)
            local go = GameObject:new(current, name)

            go:update()
            go:draw()
            if self.showProperties then
                go:printPropertiesOverRight()
            end
        end
    end
end

function GameObjectGroup:drawToggleShowPropertyButton(x, y, width, height, label)
    local area = Rect:from(x, y, width, height)
    local toggle = KeyboardInput.INSTANCE:isToggleButtonDown(area, label, self.showProperties)
    if toggle then
        self:toggleShowProperties()
    end
end

function GameObjectGroup:toggleShowProperties()
    self.showProperties = not self.showProperties
end

return GameObjectGroup
