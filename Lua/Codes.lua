local Memory = require("Memory")

--[[ Idea: Types of Codes
- Visual
- Physics
- Objects
- Different difficulty levels: easy/medium/hard?
]]

local SampleCode = {
	name = "test",
	duration = 1, -- number of frames the code lasts
	enable = function(self)
		self.powerup = 3
	end,
	update = function(self)
		self.previous_coin_count = 42
	end,
	disable = function(self)

	end,
}

local Codes = {
	{
		name = "Big Mario",
		duration = 3*60,
		enable = function(self)
			Memory.Player.Size.Set(5, 5, 5)
		end,
		disable = function(self)
			Memory.Player.Size.Set(1, 1, 1)
		end
	},
	{
		name = "Small Mario",
		duration = 30*60,
		enable = function(self)
			Memory.Player.Size.Set(0.2, 0.2, 0.2)
		end,
		disable = function(self)
			Memory.Player.Size.Set(1, 1, 1)
		end
	},
	{
		name = "Rise",
		duration = 5*60,
		update = function(self)
			Memory.Player:Update() -- update memory values as needed
			local pos = Memory.Player.Position
			Memory.Player.Position.Set(pos.X, pos.Y + 50, pos.Z)
		end
	},
	{
		name = "Random Music",
		duration = 30*60,
		update = function(self)
			if (ReadValue16(0x807C5D24) == 0) then
				ranSong = math.random(14,88)
				WriteValue32(0x807C5E04,ranSong)
			end
		end
	},
	{
		name = "Random Health",
		duration = 20*60,
		update = function(self)
			Memory.Player:Update()
			if (math.random(1,5) % 5 == 0) then
				local health = ReadValue32(Memory.Player.Address+0x380)
				WriteValue32(Memory.Player.Address+0x380,math.random(1,6))
			end
		end
	},
	{
		name = "Enable Flying",
		duration = 10*60,
		enable = function(self)
			Memory.Player:Update()
			WriteValue16(Memory.Player.Address+0x3D4,07)
		end,
		disable = function(self)
			Memory.Player:Update()
			WriteValue16(Memory.Player.Address+0x3D4,00)
		end
	},
	{
		name = "Disable Spin",
		duration = 20*60,
		enable = function(self)
			Memory.Player:Update()
			WriteValue16(Memory.Player.Address+0x3D4,09)
		end,
		disable = function(self)
			Memory.Player:Update()
			WriteValue16(Memory.Player.Address+0x3D4,00)
		end
	},
	{
		name = "Rotate Objects",
		duration = 15*60,
		update = function(self)
			for i = 6,#Memory.Objects do
				Memory.Objects[i]:Update()
				Memory.Objects[i].Rotation.Set(0,Memory.Objects[i].Rotation.Y+1,0)
			end
		end,
	},
}

return Codes
