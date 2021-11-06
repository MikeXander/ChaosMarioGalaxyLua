local Memory = {
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
    return Object:new({
    Address = tableX[1],
    Name = tableX[2],
    Position = {X = tableX[3][1], Y = tableX[3][2], Z = tableX[3][3]},
    Rotation = {X = tableX[4][1], Y = tableX[4][2], Z = tableX[4][3]},
    Size = {X = tableX[5][1], Y = tableX[5][2], Z = tableX[5][3]},
    Speed = {X = tableX[6][1], Y = tableX[6][2], Z = tableX[6][3]},
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

    objListAddress = ReadValue32(0x809A9290)
    objListStart = ReadValue32(objListAddress + 0x14)
    objCount = ReadValue32(objListAddress + 0x10)

    if objCount ~= #Memory.Objects then -- Recalculate everything if the object list has changed
        Memory.Objects = {}
        for i = 1,objCount do 
            objAddress = ReadValue32(objListStart+4*i)
            objName = getName(objAddress+4)

            objPos = {ReadValueFloat(objAddress+0x0C),ReadValueFloat(objAddress+0x10),ReadValueFloat(objAddress+0x14)}
            objRot = {ReadValueFloat(objAddress+0x18),ReadValueFloat(objAddress+0x1C),ReadValueFloat(objAddress+0x20)}
            objSize = {ReadValueFloat(objAddress+0x24),ReadValueFloat(objAddress+0x28),ReadValueFloat(objAddress+0x2C)}
            objSpeed = {ReadValueFloat(objAddress+0x30),ReadValueFloat(objAddress+0x34),ReadValueFloat(objAddress+0x38)}

            Memory.Objects[i] = Memory.newObject({objAddress, objName, objPos, objRot, objSize, objSpeed})
        end
    else
        for i = 1,objCount do
            Memory.Objects[i].Position.X = ReadValueFloat(objAddress+0x0C)
            Memory.Objects[i].Position.Y = ReadValueFloat(objAddress+0x10)
            Memory.Objects[i].Position.Z = ReadValueFloat(objAddress+0x14)
            Memory.Objects[i].Rotation.X = ReadValueFloat(objAddress+0x18)
            Memory.Objects[i].Rotation.Y = ReadValueFloat(objAddress+0x1C)
            Memory.Objects[i].Rotation.Z = ReadValueFloat(objAddress+0x20)
            Memory.Objects[i].Size.X = ReadValueFloat(objAddress+0x24)
            Memory.Objects[i].Size.Y = ReadValueFloat(objAddress+0x28)
            Memory.Objects[i].Size.Z = ReadValueFloat(objAddress+0x2C)
            Memory.Objects[i].Speed.X = ReadValueFloat(objAddress+0x30)
            Memory.Objects[i].Speed.Y = ReadValueFloat(objAddress+0x34)
            Memory.Objects[i].Speed.Z = ReadValueFloat(objAddress+0x38)
        end
    end

    if objCount >= 5 then -- Mario/Luigi's Address (TODO: Figure out cases where it isn't the 5th address ie Bubble Breeze)
        Player = Memory.Objects[5]
    end

    return Memory
end

return Memory