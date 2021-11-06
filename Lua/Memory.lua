local Memory = {
    Player = {
        Address = 0x0,
        X = 0, -- actual address references
        Y = 0, -- so other code can ReadValueFloat(Memory.Player.X)
        Z = 0
    },
    Camera = {
        X = 0,
        Y = 0,
        Z = 0
    }
}

local Address = {
    
}

function Memory.Update()
    objListAddress = ReadValue32(0x809A9290)
	objListStart = ReadValue32(objListAddress + 0x14)
	objCount = ReadValue32(objListAddress + 0x10)
	marioAddress = objListAddress + 12*4
    -- only update everything if the object list changes
end

return Memory
