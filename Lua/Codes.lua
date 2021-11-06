local Memory = require("Memory")

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
			Memory.Objects[5].Size.X = 5
			Memory.Objects[5].Size.Y = 5
			Memory.Objects[5].Size.Z = 5
		end,
		update = function(self)

		end,
		disable = function(self)
			Memory.Objects[5].Size.X = 1
			Memory.Objects[5].Size.Y = 1
			Memory.Objects[5].Size.Z = 1
		end
	},
	{
		name = "Small Mario",
		duration = 60,
		enable = function(self)
			Memory.Objects[5].Size.X = 0.2
			Memory.Objects[5].Size.Y = 0.2
			Memory.Objects[5].Size.Z = 0.2
		end,
		update = function(self)

		end,
		disable = function(self)
			Memory.Objects[5].Size.X = 1
			Memory.Objects[5].Size.Y = 1
			Memory.Objects[5].Size.Z = 1
		end
	}
}

return Codes