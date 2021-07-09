local Vector2 = require("Vector2")
local class = require("middleclass")

local MemoryAddress = class('MemoryAddress')

MemoryAddress.static.NORMAL_TEXT_COLOR = "white"
MemoryAddress.static.FRONZEN_TEXT_COLOR = 0xFF00FFFF -- Same color from the Frozen RAM Address.

function MemoryAddress:initialize(type, address, value)
    self.value = value or 0
    self.address = address or 0
    self.realValue = value or 0
    self.frozen = false
    self.frozenValue = 0
    self.type = type or "Bool"
end

MemoryAddress.static.READ = {
    Bool = function(address)
        return mainmemory.read_u8(address) == 1
    end,
    Int = mainmemory.read_u8,
    BigInt = mainmemory.read_s16_le,
    Float = mainmemory.read_s32_le,
    FloatVector = function(address)
        return Vector2:new(MemoryAddress.READ['Float'](address.x), MemoryAddress.READ['Float'](address.y))
    end,
    IntVector = function(address)
        return Vector2:new(MemoryAddress.READ['BigInt'](address.x), MemoryAddress.READ['BigInt'](address.y))
    end
}

MemoryAddress.static.WRITE = {
    Bool = mainmemory.write_s8,
    Int = mainmemory.write_u8,
    BigInt = mainmemory.write_s16_le,
    Float = mainmemory.write_s32_le,
    FloatVector = function(address, value)
        return Vector2:new(MemoryAddress.WRITE['Float'](address.x, value.x),
            MemoryAddress.WRITE['Float'](address.y, value.y))
    end,
    IntVector = function(address, value)
        return Vector2:new(MemoryAddress.WRITE['BigInt'](address.x, value.x),
            MemoryAddress.WRITE['BigInt'](address.y, value.y))
    end
}

MemoryAddress.static.MULTIPLIER = {
    Int = 1,
    BigInt = 1,
    Float = 1.0,
    IntVector = 1.0,
    FloatVector = 1.0
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
