--
-- Author: HyagoGow
-- A GameObjectGroup class for Mega Man games from PSOne.
-- This class will update a group of GameObjects.
--
local class = require("middleclass")
local GameObject = require("GameObject")
local KeyboardInput = require("KeyboardInput")
local MemoryAddress = require("MemoryAddress")

local GameObjectGroup = class('GameObjectGroup') -- Creating the GameObjectGroup class.

function GameObjectGroup:initialize(name, address)
    self.name = name
    self.address = address
    self.showProperties = false
    self.disabled = MemoryAddress:new("Bool", address.disabled)
end

function GameObjectGroup:update()
    self.disabled:update()
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

function GameObjectGroup:drawToggleShowPropertyButton(label, x, y, width, height)
    local toggle = KeyboardInput.INSTANCE:isShowHideButtonDown(label, self.showProperties, x, y, width, height)
    if toggle then
        self:toggleShowProperties()
    end
end

function GameObjectGroup:drawToggleDisabledButton(label, x, y, width, height)
    local toggle = KeyboardInput.INSTANCE:isEnableDisableButtonDown(label, not self.disabled.value, x, y, width, height)
    if toggle then
        self:toggleDisabled()
    end
end

function GameObjectGroup:toggleShowProperties()
    self.showProperties = not self.showProperties
end

function GameObjectGroup:toggleDisabled()
    local disable = not self.disabled.value
    if disable then
        self:disable()
    else
        self:enable()
    end
end

function GameObjectGroup:enable()
    self.disabled:write(false)
end

function GameObjectGroup:disable()
    self.disabled:write(true)
end

return GameObjectGroup
