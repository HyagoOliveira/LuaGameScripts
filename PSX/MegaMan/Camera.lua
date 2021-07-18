--
-- Author: HyagoGow
-- A Camera class for Mega Man X4 game.
-- This represents the camera used on the game.
--
local Mover = require("Mover")
local Vector2 = require("Vector2")
local class = require("middleclass")
local MemoryAddress = require("MemoryAddress")

local Camera = class('Camera') -- Creating the Camera class.

function Camera:initialize(address, resolution)
    self.name = "Camera"
    self.leftBorder = Vector2:new(86, 0) -- PSX emulator has a left border that needs to be add to screen space positions.
    self.position = MemoryAddress:new("FloatVector", Vector2:new(address + 0x0A, address + 0x0E))
    self.lastPosition = MemoryAddress:new("FloatVector", Vector2:new(address + 0x16, address + 0x1A))
    self.screenSize = Vector2:new()
    self.screenScale = Vector2:new()
    self.resolution = resolution or Vector2:new(800, 480) -- PSOne resolution on BizHawk emulator
    self.manualMover = Mover:new(self, 4, {up = 'Keypad8', left = 'Keypad4', right = 'Keypad6', down = 'Keypad2'})

    -- self.backgrounds[1] = address
    -- self.backgrounds[2] = self.backgrounds[1] + 0x54
    -- self.backgrounds[3] = self.backgrounds[2] + 0x54
    Camera.static.INSTANCE = self
end

function Camera:update()
    self:updatePosition()
    self:updateScreen()
    self.manualMover:update()
end

function Camera:updatePosition()
    self.position:update()
    self.lastPosition:update()
end

function Camera:updateScreen()
    self.screenSize.x = client.screenwidth()
    self.screenSize.y = client.screenheight()
    self.screenScale = self.screenSize / self.resolution
end

function Camera:printPosition(x, y)
    local label = "Camera Pos"
    self.position.value:print(x, y, label)
end

function Camera:getScreenSpacePosition(worldPosition)
    return self.leftBorder + worldPosition - self.position.value
end

function Camera:getScreenSpaceSize()
    return self.leftBorder + self.screenSize
end

return Camera
