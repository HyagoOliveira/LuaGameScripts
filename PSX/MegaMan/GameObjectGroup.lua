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
    self.visible = true
    self.showProperties = false

    local function show()
        self:show()
    end

    event.onexit(show)
    event.onloadstate(show)
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

function GameObjectGroup:drawToggleVisibilityButton(label, x, y, width, height)
    local toggle = KeyboardInput.INSTANCE:isShowHideButtonDown(label, self.visible, x, y, width, height)
    if toggle then
        self:toggleVisibility()
    end
end

function GameObjectGroup:toggleShowProperties()
    self.showProperties = not self.showProperties
end

function GameObjectGroup:toggleVisibility()
    self.visible = not self.visible
    if self.visible then
        self:show()
    else
        self:hide()
    end
end

function GameObjectGroup:show()
    MemoryAddress:UnfreezeAddress(self.address.base, 0)
end

function GameObjectGroup:hide()
    for i = 0, self.address.max - 1 do
        local current = self.address.base + i * self.address.blockSize
        local isEnabled = MemoryAddress.READ["Bool"](current)
        if not isEnabled then
            break
        end

        MemoryAddress:WriteRange(current, self.address.blockSize, 0)
    end

    MemoryAddress:FreezeAddress(self.address.base, 0)
end

return GameObjectGroup
