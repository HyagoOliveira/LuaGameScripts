--
-- Author: HyagoGow
-- A Camera class for SNES games. Only testes for Mega Man games.
-- This represents the camera used on the game.
--
local Vector2 = require("Vector2")
local class = require("middleclass")
local MemoryAddress = require("MemoryAddress")

local Camera = class('Camera') -- Creating the Camera class.

function Camera:initialize(positionAddress, resolution)
    self.position = MemoryAddress:new("SubFloatVector", positionAddress)
    self.screenSize = Vector2:new()
    self.screenScale = Vector2:new()
    self.resolution = resolution or Vector2:new(256, 224) -- SNES resolution.

    Camera.static.INSTANCE = self
end

function Camera:update()
    self.position:update()
    self:updateScreen()
end

function Camera:updateScreen()
    self.screenSize.x = client.screenwidth()
    self.screenSize.y = client.screenheight()
    self.screenScale = self.screenSize / self.resolution
end

function Camera:printPosition(x, y)
    self.position:print(x, y, "Camera Pos")
end

function Camera:getScreenSpacePosition(worldPosition)
    return worldPosition - self.position.value
end

function Camera:getScaledScreenSpacePosition(worldPosition)
    return self:getScreenSpacePosition(worldPosition) * self.screenScale
end

return Camera
