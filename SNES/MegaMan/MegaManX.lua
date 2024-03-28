--
-- Author: HyagoGow
-- This Script is for Mega Man X, Mega Man X2 or Mega Man X3 games from SNES.
-- It shows the Axis Aligned Bounding Boxes (AABB) for the player, enemies, bullets and items.
-- Also, it prints some properties next to the player.
-- The MEMORY_ADDRESS table informs where to find all necessary variables.
-- Set the emulator View > Windows Size > 3x for better resolution.
--

package.path = package.path .. ";../../?.lua" -- import lua classes into repository root folder

local Camera = require("Camera") -- Importing the Camera class.
local Vector2 = require("Vector2") -- Importing the Vector2 class.
local GameObject = require("GameObject") -- Importing the GameObject class.
local KeyboardInput = require("KeyboardInput") -- Importing the KeyboardInput class.
local GameObjectGroup = require("GameObjectGroup") -- Importing the GameObjectGroup class.

-- All classes use the middleclass library to create Object Oriented Programing (OOP) behaviour for Lua.
-- See more on https://github.com/kikito/middleclass

---------------
---CONSTANTS---
---------------
-- Memory addresses taken from the Mega Man X RAM Map: 
-- http://tasvideos.org/GameResources/SNES/MegaManX/RAMMap.html
local MEMORY_ADDRESS = {
    ["Mega Man X (USA)"] = {
        camera = {
            position = Vector2:new(0x00B4, 0x00B6) -- The camera position address.
        },
        player = {
            base = 0xBA8, -- The player base address. If the player is present on screen, all values related to him will start at this address.
            bullets = {
                base = 0x1228, -- If a player bullet is present on screen, it'll start at this address.
                blockSize = 0x40, -- Each bullet has 64 (0x40) bytes loaded on memory.
                max = 8 -- The player can shot a maximum of 8 bullets.
            }
        },
        enemy = {
            group = {
                base = 0xE68, -- If a enemy is present on screen, it'll start at this address.
                blockSize = 0x40, -- Each enemy has 64 (0x40) bytes loaded on memory.
                max = 15 -- A total of 15 enemies can be on screen.
            },
            items = {
                base = 0x1428, --  If an enemy item (bullet, weapon, life refil etc) is present on screen, it'll start at this address.
                blockSize = 0x40, -- Each item has 64 bytes loaded on memory.
                max = 8 -- A total of 8 items can be on screen.
            }
        }
    },
    ["Mega Man X2 (USA)"] = {
        camera = {
            position = Vector2:new(0x1E5D, 0x1E60) -- The camera position address.
        },
        player = {
            base = 0x9D8, -- The player base address. If the player is present on screen, all values related to him will start at this address.
            bullets = {
                base = 0x1058, -- If a player bullet is present on screen, it'll start at this address.
                blockSize = 0x40, -- Each bullet has 64 (0x40) bytes loaded on memory.
                max = 8 -- The player can shot a maximum of 8 bullets.
            }
        },
        enemy = {
            group = {
                base = 0xD18, -- If a enemy is present on screen, it'll start at this address.
                blockSize = 0x40, -- Each enemy has 64 (0x40) bytes loaded on memory.
                max = 15 -- A total of 15 enemies can be on screen.
            },
            items = {
                base = 0x12D8, --  If an enemy item (bullet, weapon, life refil etc) is present on screen, it'll start at this address.
                blockSize = 0x40, -- Each item has 64 bytes loaded on memory.
                max = 8 -- A total of 8 items can be on screen.
            }
        }
    },
    ["Mega Man X3 (USA)"] = { -- Same from Mega Man X2 (USA) since the addresses are the same.
        camera = {
            position = Vector2:new(0x1E5D, 0x1E60) -- The camera position address.
        },
        player = {
            base = 0x9D8, -- 0xBA8, -- The player base address. If the player is present on screen, all values related to him will start at this address.
            bullets = {
                base = 0x1058, -- 0x1228, -- If a player bullet is present on screen, it'll start at this address.
                blockSize = 0x40, -- Each bullet has 64 (0x40) bytes loaded on memory.
                max = 8 -- The player can shot a maximum of 8 bullets.
            }
        },
        enemy = {
            group = {
                base = 0xD18, -- 0xE68, -- If a enemy is present on screen, it'll start at this address.
                blockSize = 0x40, -- Each enemy has 64 (0x40) bytes loaded on memory.
                max = 15 -- A total of 15 enemies can be on screen.
            },
            items = {
                base = 0x12D8, -- 0x1428, --  If an enemy item (bullet, weapon, life refil etc) is present on screen, it'll start at this address.
                blockSize = 0x40, -- Each item has 64 bytes loaded on memory.
                max = 8 -- A total of 8 items can be on screen.
            }
        }
    }
}

---------------
----OBJECTS----
---------------
local gamename = gameinfo.getromname()
local gameAddress = MEMORY_ADDRESS[gamename]
local hasGameAddress = gameAddress ~= nil

if not hasGameAddress then
    console.log("This script is not compatible with this game.")
    console.log("You have to load Mega Man X (USA), Mega Man X2 (USA) or Mega Man X3 (USA) from SNES.")
    return
end

local input = KeyboardInput:new() -- Instantialing the KeyboardInput class.
local camera = Camera:new(gameAddress.camera.position) -- Instantialing the Camera class.
local player = GameObject:new(gameAddress.player.base, "Player") -- Instantialing the GameObject class for the player.
local enemiesGroup = GameObjectGroup:new("Enemy", gameAddress.enemy.group) -- Instantialing the GameObjectGroup class for the enemy group.
local enemyItemsGroup = GameObjectGroup:new("Enemy Item", gameAddress.enemy.items) -- Instantialing the GameObjectGroup class for the enemy items.
local playerBulletsGroup = GameObjectGroup:new("Player Bullet", gameAddress.player.bullets) -- Instantialing the GameObjectGroup class for the player bullets.

-- For some reason, the Player needs to add 2 pixel vertically to correctly display its screen position.
player.positionCorrection = Vector2:new(0, 2)

console.clear()
memory.usememorydomain("CARTROM")

while true do
    input:update()

    camera:update()
    camera:printPosition(0, 32)

    player:update()
    player:draw("blue")
    player:printProperties(0, 180)

    gui.drawText(98, 190, "Show Properties")
    enemiesGroup:drawToggleShowPropertyButton(100, 205, 50, 15, "Enemies")
    enemyItemsGroup:drawToggleShowPropertyButton(152, 205, 50, 15, "Items")
    playerBulletsGroup:drawToggleShowPropertyButton(204, 205, 50, 15, "Bullets")

    enemiesGroup:draw("red")
    enemyItemsGroup:draw("yellow")
    playerBulletsGroup:draw("green")

    emu.frameadvance()
end
