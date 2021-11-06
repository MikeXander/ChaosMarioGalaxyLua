local Memory = require("Memory")

--[[ TODO ?
Types of "Codes"
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

	end
}

local Codes = {
	{
		name = "Random Health",
		duration = 60,
		update = function(self)
			local frame = ReadValue32(0x806A2508) -- Memory.Frame ? Address.Frame ?
			if (frame % 5 == 0) then
				--local marioHealth = ReadValue32(Memory.Player.Address+0x380)
				--WriteValue32(Memory.Player.Address+0x380,(marioHealth+1) % 7)
			end
		end
	},
	{
		name = "A",
		duration = 60,
		update = function(self)

		end
	},
	{
		name = "Aa",
		duration = 60,
		update = function(self)

		end
	},
	{
		name = "B",
		duration = 60,
		update = function(self)

		end
	},
	{
		name = "Best Code",
		duration = 60,
		update = function(self)

		end
	},
	{
		name = "DN",
		duration = 60,
		update = function(self)

		end
	},
	{
		name = "DaCode",
		duration = 62,
		update = function(self)

		end
	},
	{
		name = "Nice",
		duration = 69,
		update = function(self)

		end
	}
}

return Codes
