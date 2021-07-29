--
-- Author: HyagoGow
-- A GameObject class for Mega Man games from PSOne.
-- This class represents a single object in the game.
--
local Rect = require("Rect")
local Camera = require("Camera")
local Vector2 = require("Vector2")
local class = require("middleclass")
local MemoryAddress = require("MemoryAddress")

local GameObject = class('GameObject') -- Creating the GameObject class.

GameObject.static.TEXT_HEIGHT = 20

function GameObject:initialize(address, name)
    -- Memory addresses found by DarkSamus. Thanks!
    self.baseAddress = address
    self.id = MemoryAddress:new("Int", address + 0x02)
    self.visible = MemoryAddress:new("Bool", address + 0x03)
    self.enabled = MemoryAddress:new("Bool", address + 0x04)
    self.action = MemoryAddress:new("Int", address + 0x05)
    self.subAction = MemoryAddress:new("Int", address + 0x06)
    self.position = MemoryAddress:new("FloatVector", Vector2:new(address + 0x0A, address + 0x0E))
    self.lastPosition = MemoryAddress:new("FloatVector", Vector2:new(address + 0x1A, address + 0x1E))
    self.screenPosition = Vector2:new() -- Position used to draw on EmuHawk UI screen space system.
    self.facing = MemoryAddress:new("Int", address + 0x15) -- (0 = Left, 64 = Right).
    self.speed = MemoryAddress:new("FloatVector", Vector2:new(address + 0x22, address + 0x26))
    self.friction = MemoryAddress:new("Float", address + 0x28)
    self.gravity = MemoryAddress:new("Float", address + 0x2E)
    self.health = MemoryAddress:new("Int", address + 0x5C)
    self.recoveryTime = MemoryAddress:new("Int", address + 0x5F) -- ??
    self.animationTimer = MemoryAddress:new("Int", address + 0x44)
    self.animationIndex = MemoryAddress:new("Int", address + 0x45)
    self.damagerCollider = MemoryAddress:new("Rect", address + 0x50) -- The Axis Alined Box Collider (AABB) used to inflict damage.
    self.damageableCollider = MemoryAddress:new("Rect", address + 0x68) -- The AABB used to detect receive damage collisions.
    self.physicalCollider = MemoryAddress:new("Rect", address + 0x54) -- The AABB used to detect physical collisions.
    self.tileCollisionSide = MemoryAddress:new("Int", address + 0x89) -- 1 = Right Wall, 2 = Left Wall, 3 = Ceiling, 4 = Ground
    self.name = name or "GameObject"
    self.textPos = Vector2:new()
    self.screenCollider = Rect:new() -- AABB used to draw on EmuHawk UI screen space system.
    self.screenColliderCorrection = Vector2:new() -- Correction to add to screenCollider
end

function GameObject:update()
    self.id:update()
    self.visible:update()
    self.enabled:update()
    self.action:update()
    self.subAction:update()
    self.facing:update()
    self.health:update()
    self.speed:update()
    self.gravity:update()
    self.friction:update()
    self.animationTimer:update()
    self.animationIndex:update()

    self:updatePosition()
    self:updateCollisions()
end

function GameObject:updatePosition()
    self.position:update()
    self.lastPosition:update()
    self.screenPosition = Camera.INSTANCE:getScreenSpacePosition(self.position.value)
end

function GameObject:updateCollisions()
    self.damagerCollider:update()
    self.physicalCollider:update()
    self.damageableCollider:update()
    self.tileCollisionSide:update()

    local isFacingRight = self.facing.value > 0
    if isFacingRight then
        -- Must flip the damager center AABB.
        self.damagerCollider.value.center.x = -self.damagerCollider.value.center.x
    end

    local screenColliderCenter = self.screenPosition + self.screenColliderCorrection
    self.screenCollider = self.physicalCollider.value
    self.screenCollider:move(screenColliderCenter)
end

function GameObject:draw()
    local screenDamagerCollider = self.damagerCollider.value
    local screenDamageableCollider = self.damageableCollider.value

    screenDamagerCollider:move(self.screenPosition)
    screenDamageableCollider:move(self.screenPosition)

    screenDamagerCollider:draw("red", 0x40FF0000)
    screenDamageableCollider:draw("green", 0x4000FF00)
    self.screenCollider:draw("white")
    self.screenPosition:draw("white", 8)
end

function GameObject:printProperties(x, y)
    self.textPos = Vector2:new(x, y)

    self:print("HP", self.health)
    self:print("Facing", self.facing)
    self:print("Gravity", self.gravity)
    self:print("Speed", self.speed)
    self:print("Pos", self.position)
    self:print("Last Pos", self.lastPosition)
    -- self:print("Action", string.format("%d Sub: %d State: %d", self.action, self.subAction, self.state))
    -- self:print("Anim", string.format("Index: %d Timer: %d", self.animationIndex, self.animationTimer))
end

function GameObject:printPropertiesOverRight()
    local position = self.screenCollider:getTopRight() + Vector2:new(2, -2)
    self:printProperties(position.x, position.y)
end

function GameObject:print(label, property)
    property:print(self.textPos.x, self.textPos.y, label)
    self.textPos.y = self.textPos.y + GameObject.TEXT_HEIGHT
end

function GameObject:toggleVisibility()
    if self.visible.frozen then
        self.visible:unfreeze()
    else
        self.visible:freezeWith(not self.visible.value)
    end
end

function GameObject:toggleEnabled()
    if self.enabled.frozen then
        self.enabled:unfreeze()
    else
        self.enabled:freezeWith(not self.enabled.value)
    end
end

function GameObject:__tostring()
    return string.format("%s. Id: %s", self.name, tostring(self.id))
end

return GameObject
