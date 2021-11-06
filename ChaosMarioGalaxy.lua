-- Authors: BillyWAR & ERGC|Xander

local random = math.random
local Distribution = require("Probabilities")
local Codes = require("Codes")

-- Note: every code is currently equally likely

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

local objListAddress = 0x0
local objListStart = 0x0
local objCount = 0
local marioAddress = 0x0


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

-- ACI: [6 7 5 _ ... 8 _]

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
		else
			Codes[c]:update()
		end
	end
end


local function ActiveCodes()
	local s = ""
	for i = 1, NumEnabledCodes do
		if i > 1 then s = s .. ", " end
		s = s .. Codes[ActiveCodeIndices[i]].name .. string.format(" (%d)", Codes[ActiveCodeIndices[i]].timer)
	end
	s = s .. "\n["
	for i = 1, NumEnabledCodes do
		if i > 1 then s = s .. ", " end
		s = s .. ActiveCodeIndices[i]
	end
	s = s .. "] ["
	for i = NumEnabledCodes + 1, #ActiveCodeIndices do
		if i > NumEnabledCodes + 1 then s = s .. ", " end
		s = s .. ActiveCodeIndices[i]
	end
	return s .. "]"
end


local function OncePerFrame()
	--Memory.Update()

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
		"\n\n\n\n\n\n\n\n\nNumEnabled: %d\nNumTarget: %d\nTimer: %d\n" .. ActiveCodes(),
		NumEnabledCodes, TargetNumCodes, ChangeTargetTimer
	))

	--[[
	
	if ReadValue32(0x806A2508) == frame then 
		SetScreenText("test")
		return end
    frame = ReadValue32(0x806A2508)

	

	objAddresses = {}
	for i = 1,objCount do
		objAddresses[i] = ReadValue32(objListAddress+i*4)
	end
	if (objCount > 11) then
		marioAddress = objAddresses[12]
	end

	--Infinite Lives
	WriteValue16(0x80F63CF0,99)
 
	--Change Positions
	exponent = math.random(-3,2)
	mantissa = math.random()+1

	if (objCount > 11) then
		ranObject = math.random(12,objCount)

		ranFloat = mantissa^exponent
		ranDirection = math.random(1,3)

		WriteValueFloat(objAddresses[ranObject]+0x20+0x04*ranDirection,ranFloat)
	end

	--Random Music
	if (ReadValue16(0x807C5D24) == 0) then
		ranSong = math.random(14,88)
		WriteValue32(0x807C5E04,ranSong)
	end


	--Flying Powerup/No Powerup
	if (frame % 10000 == 0) then
		WriteValue16(marioAddress+0x3D4,07)
	elseif (frame % 10000 == 1000) then
		WriteValue16(marioAddress+0x3D4,07)
	elseif (frame % 10000 == 5000) then
		WriteValue16(marioAddress+0x3D4,09)
	elseif (frame % 10000 == 7000) then
		WriteValue16(marioAddress+0x3D4,07)
	end]]

	--[[ Flip X Input -- a test that doesnt work
	local offsets = {0x0, 0x60, 0xC0}
	for i,o in pairs(offsets) do
		local addr = 0x661210 + o
		local x = ReadValue8(addr)
		WriteValue8(addr + 0, x == -128 and 127 or -x)
		local y = ReadValue8(addr + 1)
		WriteValue8(addr + 1, y == -128 and 127 or -y)
	end

	WriteValueFloat(0x61D3A0, -ReadValueFloat(0x61D3A0))
	WriteValueFloat(0x61D3A4, -ReadValueFloat(0x61D3A4))
	--]]
	-- 15 <--> 241
	-- 127 <--> 128
end