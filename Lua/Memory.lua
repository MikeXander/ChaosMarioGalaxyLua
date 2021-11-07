local Memory = {
    OFFSETS = {
        POSITION = 0x0C,
        ROTATION = 0x18,
        SIZE = 0x24,
        SPEED = 0x30
    },
    Objects = { -- Array of objects

    },
    Player = { -- Mario/Luigi Easy to Grab Object

    }
}

local Object = { -- Formatted Address, Name, Position, Rotation, Size, Speed
    Address = 0x00,
    Name = "",
    Position = {
        X = 0,
        Y = 0,
        Z = 0
    },
    Rotation = {
        X = 0,
        Y = 0,
        Z = 0
    },
    Size = {
        X = 0,
        Y = 0,
        Z = 0
    },
    Speed = {
        X = 0,
        Y = 0,
        Z = 0
    }
}

function Object:new(tableX) -- Constructor for a new Object

    local newObject = tableX
    setmetatable(newObject, self)
    self.__index = self
    return newObject
end

function Memory.newObject(tableX) -- Method you should actually call to make a new object
    local function set(addr)
        return function(x, y, z)
            WriteValueFloat(addr, x)
            WriteValueFloat(addr + 4, y)
            WriteValueFloat(addr + 8, z)
        end
    end
    return Object:new({
    Address = tableX[1],
    Name = tableX[2],
    Position = {X = tableX[3][1], Y = tableX[3][2], Z = tableX[3][3], Set = set(tableX[1] + Memory.OFFSETS.POSITION)},
    Rotation = {X = tableX[4][1], Y = tableX[4][2], Z = tableX[4][3], Set = set(tableX[1] + Memory.OFFSETS.ROTATION)},
    Size = {X = tableX[5][1], Y = tableX[5][2], Z = tableX[5][3], Set = set(tableX[1] + Memory.OFFSETS.SIZE)},
    Speed = {X = tableX[6][1], Y = tableX[6][2], Z = tableX[6][3], Set = set(tableX[1] + Memory.OFFSETS.SPEED)},
    Update = function(self)
        self.Position.X = ReadValueFloat(tableX[1] + Memory.OFFSETS.POSITION)
        self.Position.Y = ReadValueFloat(tableX[1] + Memory.OFFSETS.POSITION + 4)
        self.Position.Z = ReadValueFloat(tableX[1] + Memory.OFFSETS.POSITION + 8)
        self.Rotation.X = ReadValueFloat(tableX[1] + Memory.OFFSETS.ROTATION)
        self.Rotation.Y = ReadValueFloat(tableX[1] + Memory.OFFSETS.ROTATION + 4)
        self.Rotation.Z = ReadValueFloat(tableX[1] + Memory.OFFSETS.ROTATION + 8)
        self.Size.X = ReadValueFloat(tableX[1] + Memory.OFFSETS.SIZE)
        self.Size.Y = ReadValueFloat(tableX[1] + Memory.OFFSETS.SIZE + 4)
        self.Size.Z = ReadValueFloat(tableX[1] + Memory.OFFSETS.SIZE + 8)
        self.Speed.X = ReadValueFloat(tableX[1] + Memory.OFFSETS.SPEED)
        self.Speed.Y = ReadValueFloat(tableX[1] + Memory.OFFSETS.SPEED + 4)
        self.Speed.Z = ReadValueFloat(tableX[1] + Memory.OFFSETS.SPEED + 8)
    end
    })
end

function getName(endAddress) -- Finding a name for an object if available
    if ReadValue32(endAddress) < 0x91000000 then -- Finds if the object points to the right area of memory where a name exists
        return nil
    else
        stringEnd = ReadValue32(endAddress)-2 -- Works backward from the end to get the string
        objName = ""
        while ReadValueString(stringEnd,1) ~= "" do
            objName = ReadValueString(stringEnd,1) .. objName
            stringEnd = stringEnd - 1
        end
    end
    return objName
end

function Memory.Update() -- Memory Updater

    local objListAddress = ReadValue32(0x809A9290)
    local objListStart = ReadValue32(objListAddress + 0x14)
    local objCount = ReadValue32(objListAddress + 0x10)

    if objCount ~= #Memory.Objects then -- Recalculate everything if the object list has changed
        Memory.Objects = {}
        for i = 1,objCount do 
            local objAddress = ReadValue32(objListStart+4*i)
            local objName = getName(objAddress+4)

            local function ReadTriple(offset)
                return {
                    ReadValueFloat(objAddress + offset),
                    ReadValueFloat(objAddress + offset + 4),
                    ReadValueFloat(objAddress + offset + 8)
                }
            end
            local objPos = ReadTriple(Memory.OFFSETS.POSITION)
            local objRot = ReadTriple(Memory.OFFSETS.ROTATION)
            local objSize = ReadTriple(Memory.OFFSETS.SIZE)
            local objSpeed = ReadTriple(Memory.OFFSETS.SPEED)

            Memory.Objects[i] = Memory.newObject({objAddress, objName, objPos, objRot, objSize, objSpeed})
        end
    end

    if objCount >= 5 then -- Mario/Luigi's Address (TODO: Figure out cases where it isn't the 5th address ie Bubble Breeze)
        Memory.Player = Memory.Objects[5]
    end

end

return Memory
