--
-- Author: HyagoGow
-- A Memory Address class for SNES games (only tested for Mega Man games).
-- You can read, write, freeze and unfreeze any address.
-- Supported addresses:
-- Bool, Int, IntSigned, IntVector, Float, FloatVector, SubFloat, SubFloatVector and Rect.
--
local Rect = require("Rect")
local Vector2 = require("Vector2")
local class = require("middleclass")

local MemoryAddress = class('MemoryAddress')

MemoryAddress.static.NORMAL_TEXT_COLOR = "white"
MemoryAddress.static.FRONZEN_TEXT_COLOR = 0xFF00FFFF -- Same color from the Frozen RAM Address.
MemoryAddress.static.SUBPIXEL_MULTIPLIER = 1 / 256 -- One pixel has 256 positions on SNES.
MemoryAddress.static.BOXPOINTER_DISPLACEMENT = 0x28000 -- IDK what is this but it's necessary to read the Rect values.

function MemoryAddress:initialize(type, address, value)
    self.value = value or 0
    self.address = address or 0
    self.frozen = false
    self.frozenValue = 0
    self.type = type or "Bool"
end

MemoryAddress.static.READ = {
    Bool = function(address)
        return mainmemory.read_u8(address) == 1
    end,

    Int = mainmemory.read_u8,
    IntSigned = function(address)
        local isPositive = MemoryAddress.READ['Int'](address) > 0x45
        if isPositive then
            return 1
        end
        return -1
    end,
    IntVector = function(address)
        return Vector2:new(MemoryAddress.READ['BigInt'](address.x), MemoryAddress.READ['BigInt'](address.y))
    end,

    Float = function(address)
        return mainmemory.read_s16_le(address) * MemoryAddress.SUBPIXEL_MULTIPLIER
    end,
    FloatVector = function(address)
        return Vector2:new(MemoryAddress.READ['Float'](address.x), MemoryAddress.READ['Float'](address.y))
    end,

    SubFloat = function(address)
        local value = mainmemory.read_s16_le(address)
        -- A subvalue is how old machines stores float point values (0.xx)
        -- See more on https://retrocomputing.stackexchange.com/a/11127
        -- For this game, subvalues are always located at the leftmost position from its address (position - 1).
        local subvalue = mainmemory.read_u8(address - 1) * MemoryAddress.SUBPIXEL_MULTIPLIER
        return value + subvalue
    end,
    SubFloatVector = function(address)
        return Vector2:new(MemoryAddress.READ['SubFloat'](address.x), MemoryAddress.READ['SubFloat'](address.y))
    end,

    Rect = function(address)
        local pointer = mainmemory.read_u16_le(address) + MemoryAddress.BOXPOINTER_DISPLACEMENT
        local center = Vector2:new(memory.read_s8(pointer + 0), memory.read_s8(pointer + 1))
        local halfSize = Vector2:new(memory.read_u8(pointer + 2), memory.read_u8(pointer + 3))
        local size = halfSize * 2

        return Rect:new(center, size)
    end
}

MemoryAddress.static.WRITE = {
    Bool = mainmemory.write_u8,

    Int = mainmemory.write_u8,
    IntSigned = function(_)
        -- not implemented
    end,
    IntVector = function(address, value)
        MemoryAddress.WRITE['Int'](address.x, value.x)
        MemoryAddress.WRITE['Int'](address.y, value.y)
    end,

    Float = mainmemory.write_s16_le,
    FloatVector = function(address, value)
        MemoryAddress.WRITE['Float'](address.x, value.x)
        MemoryAddress.WRITE['Float'](address.y, value.y)
    end,

    Rect = function(_)
        -- not implemented
    end
}

function MemoryAddress:update()
    if self.frozen then
        self:write(self.frozenValue)
    else
        self:read()
    end
end

function MemoryAddress:read()
    self.value = MemoryAddress.READ[self.type](self.address)
end

function MemoryAddress:write(value)
    MemoryAddress.WRITE[self.type](self.address, value)
end

function MemoryAddress:print(x, y, label)
    local text = string.format("%s: %s", label, tostring(self.value))
    local color = self:getTextColor()
    -- Draws on the screen at the given coordinates.
    gui.text(x, y, text, color)
end

function MemoryAddress:toggleFreeze()
    if self.frozen then
        self:unfreeze()
    else
        self:freeze()
    end
end

function MemoryAddress:freeze()
    self:read()
    self.frozen = true
    self.frozenValue = self.value
end

function MemoryAddress:unfreeze()
    self.frozen = false
end

function MemoryAddress:getTextColor()
    if self.frozen then
        return MemoryAddress.FRONZEN_TEXT_COLOR
    end
    return MemoryAddress.NORMAL_TEXT_COLOR
end

function MemoryAddress:__tostring()
    return string.format("0x%s - %s", bizstring.hex(self.address), tostring(self.value))
end

function MemoryAddress:__eq(address)
    return self.address == address
end

function MemoryAddress:__add(address)
    return MemoryAddress:new(self.address + address)
end

function MemoryAddress:__sub(address)
    return MemoryAddress:new(self.address - address)
end

function MemoryAddress:__mul(address)
    return MemoryAddress:new(self.address * address)
end

function MemoryAddress:__div(address)
    return MemoryAddress:new(self.address / address)
end

return MemoryAddress
