--
-- Author: HyagoGow
-- A Memory Address class for PSX games (only tested for Mega Man games).
-- You can read, write, freeze and unfreeze any address.
-- Supported addresses: Bool, Int, Float, FloatVector and Rect.
--
local Rect = require("Rect")
local Vector2 = require("Vector2")
local class = require("middleclass")

local MemoryAddress = class('MemoryAddress')

MemoryAddress.static.NORMAL_TEXT_COLOR = "white"
MemoryAddress.static.FRONZEN_TEXT_COLOR = 0xFF00FFFF -- Same color from the Frozen RAM Address.
MemoryAddress.static.MULTIPLIER = {
    Int = 0.5, -- Int numbers should be multiplied by 0.5 (they must be half).
    Float = 2.0, -- Float numbers should be multiplied by 2 (they must be doubled).
    FloatVector = 2.0,
    DecimalFactor = 1 / 256
}

function MemoryAddress:initialize(type, address, value)
    self.value = value or 0
    self.realValue = value
    self.address = address or 0
    self.frozen = false
    self.frozenValue = 0
    self.type = type or "Bool"
end

MemoryAddress.static.READ = {
    Bool = function(address)
        return mainmemory.read_u8(address) >= 1
    end,

    Int = mainmemory.read_u8,

    Float = function(address)
        -- On float point numbers, the decimal part is always located at leftmost from its address (address - 1).
        -- The decimal part should be multiplied by a factor of 1/128, 1/256, 1/512 etc
        local number = mainmemory.read_s16_le(address)
        local decimal = mainmemory.read_u8(address - 1) * MemoryAddress.MULTIPLIER.DecimalFactor
        return number + decimal
    end,
    FloatVector = function(address)
        return Vector2:new(MemoryAddress.READ['Float'](address.x), MemoryAddress.READ['Float'](address.y))
    end,

    Rect = function(address)
        local pointer = mainmemory.read_u32_le(address)
        local center = Vector2:new(memory.read_s8(pointer + 0), memory.read_s8(pointer + 1))
        local halfSize = Vector2:new(memory.read_u8(pointer + 2), memory.read_u8(pointer + 3))
        local size = halfSize * 2
        return Rect:new(center, size)
    end
}

MemoryAddress.static.WRITE = {
    Bool = mainmemory.write_s8,

    Int = mainmemory.write_u8,

    Float = mainmemory.write_s16_le,
    FloatVector = function(address, value)
        MemoryAddress.WRITE['Float'](address.x, value.x)
        MemoryAddress.WRITE['Float'](address.y, value.y)
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
    self.realValue = MemoryAddress.READ[self.type](self.address)
    self.value = self.realValue

    local multiplier = MemoryAddress.MULTIPLIER[self.type]
    if multiplier then
        self.value = self.realValue * multiplier
    end
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
    self.frozenValue = self.realValue
end

function MemoryAddress:freezeWith(value)
    self.frozen = true
    self.frozenValue = value
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
