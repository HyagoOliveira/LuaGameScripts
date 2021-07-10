--
-- Author: HyagoGow
-- A GameObject class for Mega Man games from SNES.
-- This class represents a single object in the game.
-- See address table property.
--
local Rect = require("Rect")
local Camera = require("Camera")
local Vector2 = require("Vector2")
local class = require("middleclass")
local MemoryAddress = require("MemoryAddress")

local GameObject = class('GameObject') -- Creating the GameObject class.

GameObject.static.TEXT_HEIGHT = 20

function GameObject:initialize(address, name)
    -- Memory addresses displacement taken from the Enemy/Object data in
    -- http://tasvideos.org/GameResources/SNES/MegaManX/RAMMap.html

    self.enabled = MemoryAddress:new("Bool", address)
    self.id = MemoryAddress:new("Int", address + 0x0A)
    self.position = MemoryAddress:new("SubFloatVector", Vector2:new(address + 0x05, address + 0x08))
    self.lastPosition = MemoryAddress:new("SubFloatVector", Vector2:new(address + 0x22, address + 0x24))
    self.facing = MemoryAddress:new("IntSigned", address + 0x11) -- (-1 = Left, 1 = Right).
    self.speed = MemoryAddress:new("FloatVector", Vector2:new(address + 0x1A, address + 0x1C))
    self.gravity = MemoryAddress:new("Float", address + 0x1E)
    self.health = MemoryAddress:new("Int", address + 0x27)
    self.boxCollider = MemoryAddress:new("Rect", address + 0x20) -- The Axis Alined Box Collider (AABB) used to detect all collisions interactions.
    self.screenBoxCollider = Rect:new() -- AABB used to draw on EmuHawk UI screen space system.
    self.name = name or "GameObject"
    self.textPos = Vector2:new()
    self.screenPosition = Vector2:new() -- Position used to draw on EmuHawk UI screen space system.
    self.positionCorrection = Vector2:new()
end

function GameObject:update()
    self.id:update()
    self.enabled:update()
    self.facing:update()
    self.health:update()
    self.speed:update()
    self.gravity:update()

    self:updatePosition()
    self:updateBoxCollider()
end

function GameObject:updatePosition()
    self.position:update()
    self.lastPosition:update()
    self.screenPosition = Camera.INSTANCE:getScreenSpacePosition(self.position.value)

    -- Some GameObjects need a corretion on its screen position.
    self.screenPosition = self.screenPosition + self.positionCorrection
end

function GameObject:updateBoxCollider()
    self.boxCollider:update()

    self.screenBoxCollider = self.boxCollider.value
    self.screenBoxCollider:move(self.screenPosition)
end

function GameObject:draw(color)
    self.screenPosition:draw(color)
    self.screenBoxCollider:draw(color)
end

function GameObject:printProperties(x, y)
    self.textPos = Vector2:new(x, y) * Camera.INSTANCE.screenScale

    self:print("HP", self.health)
    self:print("Facing", self.facing)
    self:print("Gravity", self.gravity)
    self:print("Speed", self.speed)
    self:print("Pos", self.position)
    self:print("Last Pos", self.lastPosition)
end

function GameObject:printPropertiesOverRight()
    local position = self.screenBoxCollider:getTopRight() + Vector2:new(2, -2)
    self:printProperties(position.x, position.y)
end

function GameObject:print(label, property)
    property:print(self.textPos.x, self.textPos.y, label)
    self.textPos.y = self.textPos.y + GameObject.TEXT_HEIGHT
end

function GameObject:__tostring()
    return self.name
end

return GameObject
