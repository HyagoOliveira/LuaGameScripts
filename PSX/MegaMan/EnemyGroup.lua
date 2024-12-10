local class = require("middleclass")
local KeyboardInput = require("KeyboardInput")
local GameObjectGroup = require("GameObjectGroup")

local EnemyGroup = class('EnemyGroup', GameObjectGroup) -- Creating the EnemyGroup class inheriting from the GameObjectGroup class.

function EnemyGroup:initialize(address)
    GameObjectGroup.initialize(self, "Enemy", address)
    self.isPositionFrozen = false
end

function EnemyGroup:updateFrozenProprieties(gameObject) -- Overriding the GameObjectGroup:updateFrozenProprieties() function.
    if self.isPositionFrozen then
        gameObject.speed:freeze()
        gameObject.position:freeze()
    end
end

function EnemyGroup:drawToggleFrozenPositionButton(x, y, width, height)
    local toggle = KeyboardInput.INSTANCE:isEnableDisableButtonDown(
        "Position", not self.isPositionFrozen, x, y, width, height)

    if toggle then
        self.isPositionFrozen = not self.isPositionFrozen

        for _, go in pairs(self.gameObjects) do
            go.speed:toggleFreeze()
            go.position:toggleFreeze()
        end
    end
end

return EnemyGroup
