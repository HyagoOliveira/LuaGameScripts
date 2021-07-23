local Rect = require("Rect")
local Mover = require("Mover")
local Vector2 = require("Vector2")
local class = require("middleclass")
local GameObject = require("GameObject")
local KeyboardInput = require("KeyboardInput")
local GameObjectGroup = require("GameObjectGroup")

local Player = class('Player', GameObject) -- Creating the Player class inheriting from the GameObject class.

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
    gui.drawText(x, y, "Player Options")

    local toggleLife = KeyboardInput.INSTANCE:isToggleButtonDown("Life", self.health.frozen, x, y + 20)
    local togglePos = KeyboardInput.INSTANCE:isToggleButtonDown("Position", self.position.frozen, x + 60, y + 20)
    local toggleGravity = KeyboardInput.INSTANCE:isToggleButtonDown("Gravity", self.gravity.frozen, x, y + 40)
    local toggleSpeed = KeyboardInput.INSTANCE:isToggleButtonDown("Speed", self.speed.frozen, x + 60, y + 40)
    self.damageGroup:drawToggleShowPropertyButton("Damage Items", x, y + 60, 110)

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
