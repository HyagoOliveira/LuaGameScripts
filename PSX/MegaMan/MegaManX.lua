--
-- Author: HyagoGow
-- This Script is for Mega Man X4, Mega Man X5 or Mega Man X6 games from PSOne.
-- It shows the Axis Aligned Bounding Boxes (AABB) for the player, enemies, bullets and items.
-- Also, it prints some properties next to the Game Objects as well as display some options.
-- The MEMORY_ADDRESS table informs where to find all necessary variables for the games.
-- Before use this script, make sure your display is on Pixel Pro Mode (PSX > Options > Select Pixel Pro Mode)
--

package.path = package.path .. ";../../?.lua" -- import lua classes into repository root folder

local Camera = require("Camera")
local Player = require("Player")
local KeyboardInput = require("KeyboardInput")
local EnemyGroup = require("EnemyGroup")
local GameObjectGroup = require("GameObjectGroup")

local MEMORY_ADDRESS = {
    ["Mega Man X4 (USA)"] = { -- Those addresses are for the american version of Mega Man X4.
        camera = {
            base = 0x1419B0,  -- camera object table.
            hud = 0x1721DF
        },
        player = {
            base = 0x1418C8,      -- player object table.
            damage = {
                base = 0x1406F8,  -- If a player damage item is present on screen, it'll start at this address.
                blockSize = 0x9C, -- Each item has 156 (0x9C) bytes loaded on memory.
                max = 16,         -- The player can have a maximum of 16 damage items.
                disabled = 0x1721D1
            }
        },
        enemy = {
            group = {
                base = 0x13BED0,  -- If a enemy is present on screen, it'll start at this address.
                blockSize = 0x9C, -- Each enemy has 156 (0x9C) bytes loaded on memory.
                max = 15,         -- A total of 15 enemies can be on screen.
                disabled = 0x1721D2
            },
            items = {
                base = 0x13F328,  --  If an enemy item (bullet, weapon, life refil etc) is present on screen, it'll start at this address.
                blockSize = 0x9C, -- Each item has 156 (0x9C) bytes loaded on memory.
                max = 15,         -- A total of 15 items can be on screen.
                disabled = 0x1721D3
            }
        }
    },
    ["Mega Man X5 (USA)"] = { -- Those addresses are for the american version of Mega Man X5.
        camera = {
            base = 0x09A1F8,  -- camera object table.
            hud = 0x0D1C1F
        },
        player = {
            base = 0x09A0A0,      -- player object table.
            damage = {
                base = 0x098120,  -- If a player damage item is present on screen, it'll start at this address.
                blockSize = 0x9C, -- Each item has 156 (0x9C) bytes loaded on memory.
                max = 16,         -- The player can have a maximum of 16 damage items.
                disabled = 0x0D1C11
            }
        },
        enemy = {
            group = {
                base = 0x092090,  -- If a enemy is present on screen, it'll start at this address.
                blockSize = 0x9C, -- Each enemy has 156 (0x9C) bytes loaded on memory.
                max = 15,         -- A total of 15 enemies can be on screen.
                disabled = 0x0D1C12
            },
            items = {
                base = 0x096D98,  --  If an enemy item (bullet, weapon, life refil etc) is present on screen, it'll start at this address.
                blockSize = 0x9C, -- Each item has 156 (0x9C) bytes loaded on memory.
                max = 15,         -- A total of 15 items can be on screen.
                disabled = 0x0D1C13
            }
        }
    },
    ["Mega Man X6 (USA)"] = { -- Those addresses are for the american version of Mega Man X6.
        camera = {
            base = 0x0971F8,  -- camera object table
            hud = 0x0CCEEF
        },
        player = {
            base = 0x0970A0,      -- player object table
            damage = {
                base = 0x0950A0,  -- If a player damage item is present on screen, it'll start at this address.
                blockSize = 0x9C, -- Each item has 156 (0x9C) bytes loaded on memory.
                max = 16,         -- The player can have a maximum of 16 damage items.
                disabled = 0x0CCEE1
            }
        },
        enemy = {
            group = {
                base = 0x08EF48,  -- If a enemy is present on screen, it'll start at this address.
                blockSize = 0x9C, -- Each enemy has 156 (0x9C) bytes loaded on memory.
                max = 15,         -- A total of 15 enemies can be on screen.
                disabled = 0x0CCEE2
            },
            items = {
                base = 0x093C98,  --  If an enemy item (bullet, weapon, life refil etc) is present on screen, it'll start at this address.
                blockSize = 0x9C, -- Each item has 156 (0x9C) bytes loaded on memory.
                max = 15,         -- A total of 15 items can be on screen.
                disabled = 0x0CCEE3
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
    console.log(
        "You have to load a PSOne game file named as Mega Man X4 (USA), Mega Man X5 (USA) or Mega Man X6 (USA). Reload this script after that."
    )
    return
end

console.log(string.format("Script successfully running for '%s'", game))
console.log("Press R to reset frame.")
console.log("Press T to Take a Screenshot.")

local frame = 0
local keyboard = KeyboardInput:new()                                           -- Instantiating the KeyboardInput class.
local player = Player:new(address.player)                                      -- Instantiating the Player class.
local camera = Camera:new(address.camera)                                      -- Instantiating the Camera class.
local enemiesGroup = EnemyGroup:new(address.enemy.group)                       -- Instantiating the GameObjectGroup class for the enemy group.
local enemyItemsGroup = GameObjectGroup:new("Enemy Item", address.enemy.items) -- Instantiating the GameObjectGroup class for the enemy items.

function TakeScreenshot(advanceFrame)
    gui.clearGraphics()
    gui.cleartext()
    if advanceFrame then
        emu.frameadvance()
    end
    client.screenshot()
end

function ShowEnemyOptions(x, y)
    gui.drawText(x, y, "Enemy Options")

    enemyItemsGroup:drawToggleShowPropertyButton("Items Props", x, y + 20, 100)
    enemyItemsGroup:drawToggleDisabledButton("Items", x, y + 40, 100)

    enemiesGroup:drawToggleShowPropertyButton("Properties", x, y + 60, 100)
    enemiesGroup:drawToggleDisabledButton("Enemies", x, y + 80, 100)
    enemiesGroup:drawToggleFrozenPositionButton(x, y + 100, 100)
end

function ShowOtherOptions(x, y)
    gui.drawText(x, y, "Other Options")
    local takeScrenshot = keyboard:isButtonDown("Take Screenshot", x, y + 20, 100)
    if takeScrenshot then
        TakeScreenshot(true)
    end
end

while true do
    keyboard:update()
    camera:update()

    player:update()
    player:draw()

    enemiesGroup:update()
    enemiesGroup:draw()

    enemyItemsGroup:update()
    enemyItemsGroup:draw()

    player:printProperties(2, 280)
    camera:printPosition(2, 460)

    camera:showOptions(680, 0)
    player:showOptions(680, 120)

    ShowEnemyOptions(680, 280)
    ShowOtherOptions(680, 420)

    gui.drawText(160, 2, "R: Reset Frame\tT: Take Screenshot\tF: Frame Advance")

    if keyboard:isKey("R") then
        frame = 0
    elseif keyboard:isKey("T") then
        TakeScreenshot(false)
    end

    gui.drawText(0, 30, frame, "white", "black", 32, nill, "bold")
    frame = frame + 1

    emu.frameadvance()
end
