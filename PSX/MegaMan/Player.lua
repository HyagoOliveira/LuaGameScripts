local Rect = require("Rect")
local Mover = require("Mover")
local Vector2 = require("Vector2")
local class = require("middleclass")
local GameObject = require("GameObject")
local KeyboardInput = require("KeyboardInput")
local GameObjectGroup = require("GameObjectGroup")

local Player = class('Player', GameObject)

function Player:initialize(address)
    GameObject.initialize(self, address.base, "Player")
    self.damageGroup = GameObjectGroup:new("Player Damage", address.damage)
    self.screenColliderCorrection = Vector2:new(11, 21) -- For now, add this to correct the AABB colider center.
    self.manualMover = Mover:new(self, 4, {up = 'Keypad8', left = 'Keypad4', right = 'Keypad6', down = 'Keypad2'})
end

function Player:update() -- Overriding the GameObject:update() function.
    GameObject.update(self)
    self.manualMover:update()
end

function Player:draw() -- Overriding the GameObject:draw() function.
    GameObject.draw(self)
    self.damageGroup:draw()
end

function Player:drawOptions(x, y)
    local pos = Vector2:new(x, y)
    local lifeArea = Rect:from(x, y + 20, 50, 16)
    local posArea = Rect:from(x + 60, y + 20, 50, 16)
    local gravityArea = Rect:from(x, y + 40, 50, 16)
    local speedArea = Rect:from(x + 60, y + 40, 50, 16)

    gui.drawText(pos.x, pos.y, "Player Options")

    local toggleLife = KeyboardInput.INSTANCE:isToggleButtonDown(lifeArea, "Life", self.health.frozen)
    local togglePos = KeyboardInput.INSTANCE:isToggleButtonDown(posArea, "Position", self.position.frozen)
    local toggleGravity = KeyboardInput.INSTANCE:isToggleButtonDown(gravityArea, "Gravity", self.gravity.frozen)
    local toggleSpeed = KeyboardInput.INSTANCE:isToggleButtonDown(speedArea, "Speed", self.speed.frozen)
    self.damageGroup:drawToggleShowPropertyButton(x, y + 60, 110, 16, "Damage Items")

    if toggleLife then
        self.health:toggleFreeze()
    end
    if togglePos then
        self.position:toggleFreeze()
    end
    if toggleGravity then
        self.gravity:toggleFreeze()
    end
    if toggleSpeed then
        self.speed:toggleFreeze()
    end
end

return Player
