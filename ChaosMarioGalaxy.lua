--[[

Chaos Mario Galaxy v-1.1
by BillyWAR and Xander

]]

local random = math.random
local Distribution = require("Probabilities")
local Codes = require("Codes")
local Memory = require("Memory")

-- Note: every code is equally likely

local function TEXT(msg) -- debug messages
	if false then
		MsgBox(msg)
	end
end

function onScriptStart()

end

function onScriptCancel()
    MsgBox("Script Closed")
    SetScreenText("")
end

local NumEnabledCodes = 0
local TargetNumCodes = 2
local ChangeTargetTimer = 0 -- once it hits 0 choose new codes
local ActiveCodeIndices = {} -- the first NumEnabledCodes entries are codes in use
for i = 1, #Codes do ActiveCodeIndices[i] = i end


-- idea: recently used codes less likely
-- move disabled codes to back of array
-- have it's own distribution
local function ReplaceCode(CurrentIndex)
	local new_index = random(NumEnabledCodes + 1, #Codes)
	local swap = ActiveCodeIndices[CurrentIndex]
	ActiveCodeIndices[CurrentIndex] = ActiveCodeIndices[new_index]
	ActiveCodeIndices[new_index] = swap
	Codes[ActiveCodeIndices[CurrentIndex]].timer = Distribution.ShortCodeDelay()
end


local function EnableNewCode()
	NumEnabledCodes = NumEnabledCodes + 1
	local new_index = random(NumEnabledCodes, #Codes)
	local swap = ActiveCodeIndices[NumEnabledCodes]
	ActiveCodeIndices[NumEnabledCodes] = ActiveCodeIndices[new_index]
	ActiveCodeIndices[new_index] = swap
	Codes[ActiveCodeIndices[NumEnabledCodes]].timer = Distribution.LongCodeDelay()

	TEXT(string.format("New %d (%d)", ActiveCodeIndices[NumEnabledCodes], Codes[ActiveCodeIndices[NumEnabledCodes]].timer))
end


local function UpdateCodes()
	for i = 1, NumEnabledCodes do
		local c = ActiveCodeIndices[i]
		Codes[c].timer = Codes[c].timer + 1
		if Codes[c].timer == 1 then
			TEXT("Enabled: " .. Codes[c].name)
			if Codes[c].enable then
				Codes[c]:enable()
			end
		elseif Codes[c].timer >= Codes[c].duration then
			TEXT("Replace")
			if Codes[c].disable then
				Codes[c]:disable()
			end
			if NumEnabledCodes <= TargetNumCodes then
				ReplaceCode(i)
			else
				NumEnabledCodes = NumEnabledCodes - 1
				local swap = ActiveCodeIndices[NumEnabledCodes]
				ActiveCodeIndices[NumEnabledCodes] = c
				ActiveCodeIndices[i] = swap
				i = i - 1
			end
		elseif Codes[c].timer > 0 and Codes[c].update then
			Codes[c]:update()
		end
	end
end


local function ActiveCodes()
	local names = ""
	for i = 1, NumEnabledCodes do
		if i > 1 then names = names .. ", " end
		names = names .. Codes[ActiveCodeIndices[i]].name .. string.format(" (%d)", Codes[ActiveCodeIndices[i]].timer)
	end
	local indices = "["
	for i = 1, #ActiveCodeIndices do
		if 1 < i and i ~= NumEnabledCodes + 1 then indices = indices .. ", " end
		indices = indices .. ActiveCodeIndices[i]
		if i == NumEnabledCodes then indices = indices .. "] [" end
	end
	return names .. "\n" .. indices .. "]"
end


local function OncePerFrame()
	Memory.Update()

	-- Update the number of codes running at any given moment
	if ChangeTargetTimer == 0 then
		TargetNumCodes = Distribution.NumCodes()
		if TargetNumCodes > NumEnabledCodes then
			for i = NumEnabledCodes + 1, TargetNumCodes do
				EnableNewCode()
			end
		end
		ChangeTargetTimer = Distribution.TargetTimer()
	else
		ChangeTargetTimer = ChangeTargetTimer - 1
	end

	UpdateCodes()
end


local Lastframe = -1
function onScriptUpdate()

	if GetFrameCount() == Lastframe then return end
	Lastframe = GetFrameCount()

	OncePerFrame()

	SetScreenText(string.format(
		"\n\n\n\n\nNumEnabled: %d\nNumTarget: %d\nTimer: %d\n" .. ActiveCodes() .. "\n\nObject Count: %d\n",
		NumEnabledCodes, TargetNumCodes, ChangeTargetTimer, #Memory.Objects
	))
end
