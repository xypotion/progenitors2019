--[[
TODO
show assignments
add location submenu
limit assignments by location
add ? ...shit. lol
undo button
reset button
show assignment info (duration, description, cost)
for "expedition" assignments, show area info
+ add "goal" submenu
add mate submenu to Mate & stuff
show resources (should probably be universal)
mouse input...
actual assignement resolution...
--]]

function assignmentsStart()	
	--index unassigned units
	unassignedIDs = {}
	local i = 1
	for k,v in ipairs(roster) do
	  unassignedIDs[i] = k
	  i = i + 1
	end
	-- tablePrint( unassignedIDs)
	--TODO you want to let player skip forward and backward through list, so re-implement "currentUnitIndex", lol
	
	--activity menu 
	activities = {
		a = "Alchemy",
		b = "Bulk", --? i.e. bulk up (eat a lot more food, for growth)
		c = "Construct", --rooms
		d = "Dig",
		e = "Enlarge", --rooms
		f = "Fast",
		g = "Gather",
		h = "Heal", --others! not self
		i = "Investigate",
		m = "Mate",
		p = "Preserve", --food
		s = "SORT", --? just to sort unassigned units, but maybe list elsewhere...
		t = "Train",
		w = "Welcome", --? at the gate. "Greet" would be better...
		x = "Empty", --turn any room into an Empty room
		z = "Idle",
		-- x = "Recuperate" --happens automatically when wounded BUT TODO player must choose what room to put unit in
	}
	-- tablePrint(activities)

	--initialize unit assignments table
	unitAssignments = {}
	for k, a in pairs(activities) do
		unitAssignments[a] = {}
		--TODO also add valid rooms (with capacities) and world areas (? or those can be added later as units are assigned)
	end
	
	--find all destinations
	allDestinations = {}
	for k,a in pairs(activities) do
		allDestinations[a] = findDestinations(a)
	end
	
	-- tablePrint(allDestinations)
	
	-- tablePrint(roster[1])
end

function assignmentsUpdate(dt)
end

function assignmentsDraw()
	--draw current unit summary
	drawUnitSummary(roster[unassignedIDs[1]], 50, 50)
	
	white()
	
	--draw unassigned unit icons
	love.graphics.print("Unassigned", 600, 48)
	for k, index in ipairs(unassignedIDs) do
		drawUnitIcon(roster[index], 600 + ((k - 1) % 16 + 1) * 32, 32 + math.floor((k - 1) / 16 + 1) * 32)
	end
	
	white()
	
	--draw activities menu
	local i = 0
	for k, a in pairs(activities) do
		love.graphics.print(k, 100, 200 + i * 30)
		love.graphics.print(a, 130, 200 + i * 30)
		i = i + 1
	end
	
	--debug... draw all Train destinations
	-- i = 0
	-- for k,d in pairs(allDestinations.Train) do
	-- 	love.graphics.print(k, 300, 200 + i * 30)
	-- 	love.graphics.print(d.uniqueName, 350, 200 + i * 30)
	-- 	i = i + 1
	-- end
	
	for k,v in pairs(unitAssignments) do
		if v[1] then 
			love.graphics.print(k, 500, 500)
		end
	end
end

function assignmentsKeyPressed(key)
	--TODO enable capital letters

	--was this a valid activity?
	if activities[key] then
		assignUnitTo(unassignedIDs[1], activities[key])
		table.remove(unassignedIDs, 1)
	-- else
		-- print(key.." is not an activity we provide")
	end
	
	-- tablePrint(unassignedIDs)
	
	--TODO submenus for locations, etc
	
	--DEBUG shit
	if key == "\\" then
		print("\\ - all units without medals assigned to Idle")
		-- tablePrint(unassignedIDs)
		local i = 1
		local num = #unassignedIDs
		while i <= num do
			if not roster[unassignedIDs[i]].bestMedal then
				assignUnitTo(unassignedIDs[i], "Idle")
				table.remove(unassignedIDs, i)
				num = num - 1
			else
				i = i + 1
			end
		end
	end
	
	if key == "[" then
		print("[ - sort unassigned by INT")
		table.sort(unassignedIDs, function(a,b) return ((roster[a].stats.int > roster[b].stats.int)) end)
	end
	
	if key == "]" then
		print("] - sort unassigned by STR")
		table.sort(unassignedIDs, function(a,b) return ((roster[a].stats.str > roster[b].stats.str)) end)
	end
	
	if key == "=" then
		print("= - sort unassigned by HP")
		table.sort(unassignedIDs, function(a,b) return ((roster[a].stats.maxHP > roster[b].stats.maxHP)) end)
	end
	
	if key == "-" then
		print("- - sort unassigned by AGL")
		table.sort(unassignedIDs, function(a,b) return ((roster[a].stats.agl > roster[b].stats.agl)) end)
	end
	
	if key == "/" then
		print("/ - start fresh")
		love.load()
	end
end



function assignUnitTo(rIndex, activity)
	table.insert(unitAssignments[activity], rIndex)
	print(rIndex..", "..roster[rIndex].name.." assigned to "..activity)
end

function findDestinations(a)
	d = {}
	
	if a == "Train" then
		d.space = world[1] --should always be foothills
		
		--look at all rooms, finding Dojos
		rn = 1 --"room number"
		for k,r in pairs(mountain.rooms) do
			if r.type == "Dojo" then
				d[rn] = r
				rn = rn + 1
			end
		end
	end
	
	return d
end


-- function drawAllUnits()
-- 	for k, v in pairs (roster) do
-- 		drawUnit(v, math.floor(k/20) * 150 + 10, 50 + (k % 20) * 20)
-- 	end
-- end