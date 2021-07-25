--
-- Author: HyagoGow
-- A Camera class for Mega Man X4 game.
-- This represents the camera used on the game.
--
local Mover = require("Mover")
local Vector2 = require("Vector2")
local class = require("middleclass")
local MemoryAddress = require("MemoryAddress")
local KeyboardInput = require("KeyboardInput")

local Camera = class('Camera') -- Creating the Camera class.

function Camera:initialize(address, resolution)
    self.name = "Camera"
    self.leftBorder = Vector2:new(86, 0) -- PSX emulator has a left border that needs to be add to screen space positions.
    self.position = MemoryAddress:new("FloatVector", Vector2:new(address.base + 0x0A, address.base + 0x0E))
    self.lastPosition = MemoryAddress:new("FloatVector", Vector2:new(address.base + 0x16, address.base + 0x1A))
    self.screenSize = Vector2:new()
    self.screenScale = Vector2:new()
    self.resolution = resolution or Vector2:new(800, 480) -- PSOne resolution on BizHawk emulator
    self.hud = MemoryAddress:new("Bool", address.hud)
    self.manualMover = Mover:new(self, 4, {up = 'Keypad8', left = 'Keypad4', right = 'Keypad6', down = 'Keypad2'})
    self.backgrounds = {
        MemoryAddress:new("Bool", address.base + 3),
        MemoryAddress:new("Bool", address.base + 3 + 0x54),
        MemoryAddress:new("Bool", address.base + 3 + 0x54 * 2)
    }

    Camera.static.INSTANCE = self
end

function Camera:update()
    self.hud:update()
    self:updatePosition()
    self:updateScreen()
    self.manualMover:update()

    for _, background in pairs(self.backgrounds) do
        background:update()
    end
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

function Camera:showOptions(x, y)
    gui.drawText(x, y, "Camera Options")
    self.manualMover:drawToggleButton(x, y + 20, 100)

    local toggleHUD = KeyboardInput.INSTANCE:isShowHideButtonDown("HUD", self.hud.value, x, y + 40, 100)

    if toggleHUD then
        self:toggleHUD()
    end

    for i, background in pairs(self.backgrounds) do
        local toggle =
            KeyboardInput.INSTANCE:isShowHideButtonDown("Bg " .. i, background.value, x, y + 40 + i * 20, 100)
        if toggle then
            self:toggleBackground(i)
        end
    end
end

function Camera:printPosition(x, y)
    local message = string.format("Camera: %s", tostring(self.position.value))
    gui.drawText(x, y, message)
end

function Camera:print(x, y, message, forecolor, anchor)
    local position = Vector2:new(x, y) * self.screenScale
    gui.text(position.x, position.y, message, forecolor, anchor)
end

function Camera:getScreenSpacePosition(worldPosition)
    return self.leftBorder + worldPosition - self.position.value
end

function Camera:getScreenSpaceSize()
    return self.leftBorder + self.screenSize
end

function Camera:toggleHUD()
    self.hud:write(not self.hud.value)
end

function Camera:toggleBackground(index)
    self.backgrounds[index]:write(not self.backgrounds[index].value)
end

return Camera
