----------------------------------------------------------------------------------
-- Aligns and distributes display objects
-- Usage:
-- you must provide the alignment options and a table with the list of display objects to align/distribute.
-- The first display object in the table will be used as reference to align all other objects.
-- Example:
-- place.align(place.DISTRIBUTE_RIGHT,[rect1, rect2]) 
-- will place rect2 by the right side of rect1 using the rect1.x + rect.width as reference..
--
-- Available alignment and distribution options are:
--
-- DISTRIBUTE_RIGHT, DISTRIBUTE_LEFT, DISTRIBUTE_UP & DISTRIBUTE_DOWN
-- RIGHT, LEFT, TOP & BOTTOM
-- CENTER_HORIZONTAL & CENTER_VERTICAL
----------------------------------------------------------------------------------

local M = {}
require('yam.utils.bit')

M.right = 1
M.left = 2
M.top = 4
M.bottom = 8
-- M.center = 16
M.centerHorizontal = 32
M.centerVertical = 64
M.distributeRight = 128
M.distributeLeft = 256
M.distributeUp = 512
M.distributeDown = 1024

local function placeTo(items, prop, size, operator)
	local c = 2

	items[1].x = items[1].x
	items[1].y = items[1].y

	while (c <= #items) do
		local reffSize = items[c - 1][size];
		local reffPos = items[c - 1][prop];
		local sizing = items[c][size];
		local objPos = items[c][prop];

		if operator == 1 then
			items[c][prop] = (reffPos + reffSize) 
		else
			items[c][prop] = (reffPos - sizing) 
		end
		-- items[c][prop] = items[c][prop] + ((reffPos - objPos) * operator + sizing) * operator;	

		c = c+1
	end
end

local function placeBy(items, prop, size, operator)
	local c = 2
	items[1].x = items[1].x
	items[1].y = items[1].y

	local reffSize = items[1][size];
	local reffPos = items[1][prop];
	while (c <= #items) do
		if(items[c] ~= nil) then
			local objSize = items[c][size]
			local objPos = items[c][prop]
			local sizing = reffSize
			
			local s = sizing - objSize
			if(operator == 1) then
				s = 0
			end
			items[c][prop] = items[c][prop] + ((((reffPos - objPos + s)) * operator) * operator)
		end
		c = c+1
	end
end

local function placeCenter(items, prop, size)
	local c = 2;
	items[1].x = items[1].x
	items[1].y = items[1].y

	local sizing = forceSize
	local reffSize = items[1][size]
	local reffPos = items[1][prop]
	local reff = reffSize/2	

	while (c <= #items) do
		local sizing = items[c][size];
		local objPos = items[c][prop];
		items[c][prop] = items[c][prop] - ((objPos - reffPos) + (sizing * .5 - reff));
		
		c = c+1
	end
end

function M.align(alignment, items)

	-- Safety check
	if #items == 0 then
		return
	end

	if(bit.band(alignment, M.right) ~= 0) then
		placeBy(items, "x", "width", -1)
	end
	if(bit.band(alignment, M.left) ~= 0) then
		placeBy(items, "x", "width", 1)
	end
	if(bit.band(alignment, M.top) ~= 0) then
		placeBy(items, "y", "height", 1)
	end
	if(bit.band(alignment, M.bottom) ~= 0) then
		placeBy(items, "y", "height", -1)
	end
	if(bit.band(alignment, M.centerHorizontal) ~= 0) then
		placeCenter(items, "x","width")
	end
	if(bit.band(alignment, M.centerVertical) ~= 0) then
		placeCenter(items, "y","height")
	end
	if(bit.band(alignment, M.distributeRight) ~= 0) then
		placeTo(items, "x", "width", 1)
	end
	if(bit.band(alignment, M.distributeLeft) ~= 0) then
		placeTo(items, "x","width", -1)
	end
	if(bit.band(alignment, M.distributeUp) ~= 0) then
		placeTo(items, "y", "height", -1)
	end
	if(bit.band(alignment, M.distributeDown) ~= 0) then
		placeTo(items, "y", "height", 1)
	end

end

return M