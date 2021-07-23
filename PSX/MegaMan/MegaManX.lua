--
-- Author: HyagoGow
-- This Script is for Mega Man X4, Mega Man X5 or Mega Man X6 games from PSOne.
-- It shows the Axis Aligned Bounding Boxes (AABB) for the player, enemies, bullets and items.
-- Also, it prints some properties next to the Game Objects as well as display some options.
-- The MEMORY_ADDRESS table informs where to find all necessary variables for the games.
-- Before use this script, make sure your display is on Pixel Pro Mode (PSX > Options > Select Pixel Pro Mode)
--
package.loaded["Camera"] = nil

local Camera = require("Camera")
local Player = require("Player")
local KeyboardInput = require("KeyboardInput")
local GameObjectGroup = require("GameObjectGroup")

local MEMORY_ADDRESS = {
    ["Mega Man X4 (USA)"] = { -- Those addresses are for the american version of Mega Man X4.
        camera = {
            base = 0x1419B0, -- camera object table.
            hud = 0x1776A7
        },
        player = {
            base = 0x1418C8, -- player object table.
            damage = {
                base = 0x1406F8, -- If a player damage item is present on screen, it'll start at this address.
                blockSize = 0x9C, -- Each item has 156 (0x9C) bytes loaded on memory.
                max = 16 -- The player can have a maximum of 16 damage items.
            }
        },
        enemy = {
            group = {
                base = 0x13BED0, -- If a enemy is present on screen, it'll start at this address.
                blockSize = 0x9C, -- Each enemy has 156 (0x9C) bytes loaded on memory.
                max = 15 -- A total of 15 enemies can be on screen.
            },
            items = {
                base = 0x13F328, --  If an enemy item (bullet, weapon, life refil etc) is present on screen, it'll start at this address.
                blockSize = 0x9C, -- Each item has 156 (0x9C) bytes loaded on memory.
                max = 15 -- A total of 15 items can be on screen.
            }
        }
    },
    ["Mega Man X5 (USA)"] = { -- Those addresses are for the american version of Mega Man X5.
        camera = {
            base = 0x09A2A0, -- camera object table.
            hud = 0x1776A7
        },
        player = {
            base = 0x09A0A0, -- player object table.
            damage = {
                base = 0x098120, -- If a player damage item is present on screen, it'll start at this address.
                blockSize = 0x9C, -- Each item has 156 (0x9C) bytes loaded on memory.
                max = 16 -- The player can have a maximum of 16 damage items.
            }
        },
        enemy = {
            group = {
                base = 0x092090, -- If a enemy is present on screen, it'll start at this address.
                blockSize = 0x9C, -- Each enemy has 156 (0x9C) bytes loaded on memory.
                max = 15 -- A total of 15 enemies can be on screen.
            },
            items = {
                base = 0x096D98, --  If an enemy item (bullet, weapon, life refil etc) is present on screen, it'll start at this address.
                blockSize = 0x9C, -- Each item has 156 (0x9C) bytes loaded on memory.
                max = 15 -- A total of 15 items can be on screen.
            }
        }
    },
    ["Mega Man X6 (USA)"] = { -- Those addresses are for the american version of Mega Man X6.
        camera = {
            base = 0x0971F8, -- camera object table
            hud = 0x0CCEEF
        },
        player = {
            base = 0x0970A0, -- player object table
            damage = {
                base = 0x0950A0, -- If a player damage item is present on screen, it'll start at this address.
                blockSize = 0x9C, -- Each item has 156 (0x9C) bytes loaded on memory.
                max = 16 -- The player can have a maximum of 16 damage items.
            }
        },
        enemy = {
            group = {
                base = 0x08EF48, -- If a enemy is present on screen, it'll start at this address.
                blockSize = 0x9C, -- Each enemy has 156 (0x9C) bytes loaded on memory.
                max = 15 -- A total of 15 enemies can be on screen.
            },
            items = {
                base = 0x093C98, --  If an enemy item (bullet, weapon, life refil etc) is present on screen, it'll start at this address.
                blockSize = 0x9C, -- Each item has 156 (0x9C) bytes loaded on memory.
                max = 15 -- A total of 15 items can be on screen.
            }
        }
    }
}

local game = gameinfo.getromname()
local address = MEMORY_ADDRESS[game]
local hasAddress = address ~= nil

console.clear()
if not hasAddress then
    console.log("This script is not compatible with this game.")
    console.log("You have to load a PSOne game file named as Mega Man X4 (USA), Mega Man X5 (USA) or Mega Man X6 (USA).")
    return
end

console.log(string.format("Script successfully running for '%s'", game))

local keyboard = KeyboardInput:new() -- Instantiating the KeyboardInput class.
local player = Player:new(address.player) -- Instantiating the Player class.
local camera = Camera:new(address.camera) -- Instantiating the Camera class.
local enemiesGroup = GameObjectGroup:new("Enemy", address.enemy.group) -- Instantiating the GameObjectGroup class for the enemy group.
local enemyItemsGroup = GameObjectGroup:new("Enemy Item", address.enemy.items) -- Instantiating the GameObjectGroup class for the enemy items.

while true do
    keyboard:update()
    camera:update()

    player:update()
    player:draw()

    enemiesGroup:draw()
    enemyItemsGroup:draw()

    player:printProperties(2, 330)
    camera:printPosition(2, 460)

    camera:showOptions(680, 0)
    player:drawOptions(680, 120)

    --[[
    gui.drawText(680, 120, "Show Properties")
    enemiesGroup:drawToggleShowPropertyButton("Enemies", 680, 140, 100)
    enemyItemsGroup:drawToggleShowPropertyButton("Enemies Items", 680, 160, 100)
    ]] --

    emu.frameadvance()
end
