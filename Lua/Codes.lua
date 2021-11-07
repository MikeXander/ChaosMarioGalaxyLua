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
		duration = 60,
		enable = function(self)
			Memory.Player.Size.Set(5, 5, 5)
		end,
		disable = function(self)
			Memory.Player.Size.Set(1, 1, 1)
		end
	},
	{
		name = "Small Mario",
		duration = 60,
		enable = function(self)
			Memory.Player.Size.Set(0.2, 0.2, 0.2)
		end,
		disable = function(self)
			Memory.Player.Size.Set(1, 1, 1)
		end
	},
	{
		name = "Rise",
		duration = 30,
		update = function(self)
			Memory.Player:Update() -- update memory values as needed
			local pos = Memory.Player.Position
			Memory.Player.Position.Set(pos.X, pos.Y + 50, pos.Z)
		end
	}
}

return Codes
