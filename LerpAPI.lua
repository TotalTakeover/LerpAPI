-- LerpAPI
-- By:
--   _________  ________  _________  ________  ___
--  |\___   ___\\   __  \|\___   ___\\   __  \|\  \
--  \|___ \  \_\ \  \|\  \|___ \  \_\ \  \|\  \ \  \
--       \ \  \ \ \  \\\  \   \ \  \ \ \   __  \ \  \
--        \ \  \ \ \  \\\  \   \ \  \ \ \  \ \  \ \  \____
--         \ \__\ \ \_______\   \ \__\ \ \__\ \__\ \_______\
--          \|__|  \|_______|    \|__|  \|__|\|__|\|_______|
--
-- Version: 1.2.0

-- Create API
local lerpAPI = {}

-- Interal lerp data
local lerpInternal = {}

-- Lerps table
local lerps = {}

-- Removes lerp
function lerpInternal:remove()
	
	lerps[self] = nil
	
end

-- Resets lerp, with optional target
function lerpInternal:reset(pos)
	
	-- Reset variables
	pos = pos or 0
	self.prevTick = pos
	self.currTick = pos
	self.target   = pos
	self.currPos  = pos
	self.vel      = 0
	
	-- Return object
	return self
	
end

-- Create a lerp object
function lerpAPI:new(pos, stiff, damp, mass)
	
	-- Create object
	local obj = setmetatable({}, { __index = lerpInternal })
	
	--[[
		Lerp variables:
		The initial variables the lerp uses to control it position, in tick and render
	--]]
	obj:reset(pos)
	
	--[[
		Stiffness:
		How fast the object moves towards its target (in percentage each tick)
		0 means it will never approach the target
		1 means it will reach the target within the tick
	--]]
	obj.stiff = stiff or 0.2
	
	--[[
		Damping:
		How much an object is allowed to bounce around its target
		0 means it will never reach its target due to bouncing
		1 means it wont bounce around the target
	--]]
	obj.damp = damp or 1
	
	--[[
		Mass:
		How long it takes for the object to change velocity
		Cannot have a mass of 0, otherwise divide by 0 errors will occur
		You can *still* do 0 by changing it in field, but ur asking for issues at that point
	--]] 
	if mass == 0 then error("\n\n§6Mass cannot be 0.\n§c", 2) end
	obj.mass = mass or 1

	-- Lerp enabled
	obj.enabled = true
	
	-- Add object to list
	lerps[obj] = obj
	
	-- Return object
	return obj
	
end

-- Iterate through the lerps to set the next tick of each lerp
events.TICK:register(function()
	for _, obj in pairs(lerps) do
		if obj.enabled then
			
			-- Reset ticks
			obj.prevTick = obj.currTick
			
			-- Calc
			local fSpring = -obj.stiff * (obj.currTick - obj.target)
			local fDamp   = -obj.damp * obj.vel
			local acc     = (fSpring + fDamp) / obj.mass
			
			-- Apply
			obj.vel = obj.vel + acc
			obj.currTick = obj.currTick + obj.vel
			
		end
	end
end, "tickLerp")

-- Iterate through the lerps to smooth the lerp each frame
events.RENDER:register(function(delta, context)
	for _, obj in pairs(lerps) do
		if obj.enabled then
			
			-- Apply
			obj.currPos = math.lerp(obj.prevTick, obj.currTick, delta)
			
		end
	end
end, "renderLerp")

-- Return API
return lerpAPI