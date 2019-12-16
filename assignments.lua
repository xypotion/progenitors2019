--[[
TODO
add locations & submenus
	before assigning unit to activity, check mountain for rooms of valid type(s)
		whatever rooms found that are not full, offer as possible locations for activity
			whatever room the player chooses, add that to the activity's locations if necessary, then insert rosterIndex
		if no rooms are found, then "nowhere to do that!"; this should only happen when all valid locations are FULL
		...so should candidate rooms be removed from validActivities as they fill up? and validActivities be removed if they run out of rooms?
  if outdoor activity, offer all areas
limit assignments by location
show medals only sometimes. a toggle or something
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
	rh = 32 --row height, in pixels
	
	--index unassigned units
	unassignedIDs = {}
	local i = 1
	for k,v in ipairs(roster) do
	  unassignedIDs[i] = k
	  i = i + 1
	end
	-- tablePrint(unassignedIDs)
	--TODO you want to let player skip forward and backward through list, so re-implement "currentUnitIndex", lol

	--what activities can actually be done?
	validActivities = {}
	for k,a in pairs(activities) do
		-- print(a.name)
		
		--is it an "outside" activity?
		if a.outside then
			table.insert(validActivities, deepClone(a))
		else
			--if no, then check all rooms in mountain; find any valid ones? or is this an "always" activity? then add
			if a.validRooms or a.always then --slightly redundant TODO maybe refactor this whole block at some point
				local validActivityRoomTypes = a.validRooms or {} --a little janky but meh
				local validMountainRoomIDs = {}
				
				for i,r in pairs(mountain.rooms) do
					if tableContains(validActivityRoomTypes, r.type) then
						table.insert(validMountainRoomIDs, i)
					end
				end
				
				if validMountainRoomIDs[1] or a.always then
					local va = deepClone(a)
					va.candidateRoomIDs = deepClone(validMountainRoomIDs)
					table.insert(validActivities, va) 
				end
			end
		end
	end
	
	-- tablePrint(validActivities)

	--initialize unit assignments table
	unitAssignments = {}
	for i, a in ipairs(validActivities) do
		unitAssignments[i] = {
			name = a.name,
			description = a.description,
			locations = {{}}, --TODO DEBUG for now. eventually fill with valid locations
			count = 0,
			rowsAbove = 0
		}
		--TODO also add valid rooms (with capacities) and world areas (? or those can be added later as units are assigned)
	end
	
	submenu1 = {}
	submenu2 = {}
	
	--find all destinations
	-- allDestinations = {}
	-- for k,a in pairs(validActivities) do
	-- 	allDestinations[a] = findDestinations(a)
	-- end
	
	-- tablePrint(allDestinations)
	
	-- tablePrint(roster[1])
end

function assignmentsUpdate(dt)
end

function drawUnitIconsFromRIDListAt(list, xOffset, yOffset)
	for k, index in ipairs(list) do
		-- if list[1] then
		-- tablePrint(list)
			drawUnitIcon(roster[index], xOffset + ((k - 1) % 16 + 1) * 32, yOffset + math.floor((k - 1) / 16 + 1) * rh)
		-- end
	end
end 

function assignmentsDraw()
	--draw current unit summary, nice and big
	drawUnitSummary(roster[unassignedIDs[1]], 50, 50)
	
	white()
	
	--draw unassigned unit icons
	love.graphics.print("Unassigned", 600, rh * 1)
	-- for k, index in ipairs(unassignedIDs) do
	-- 	drawUnitIcon(roster[index], 600 + ((k - 1) % 16 + 1) * 32, rh * 1 + math.floor((k - 1) / 16 + 1) * rh)
	-- end
	drawUnitIconsFromRIDListAt(unassignedIDs, 600, rh*1)
	
	white()
	
	love.graphics.print("Select activity for this unit this month:", 50, 165)
	
	--draw activities menu
	for k, a in ipairs(validActivities) do
		love.graphics.print(a.key, 50, 165 + k * rh) --TODO make this look like a key
		love.graphics.print(a.name, 80, 165 + k * rh)
	end
	
	--draw submenu1 if it's been populated
	if submenu1.label then --a little hacky, but should work, right? maybe reconsider later on TODO
		love.graphics.print(submenu1.label, 300, 200)
		
		for k,v in ipairs(submenu1) do
			love.graphics.print(k, 350, 200 + k * rh) --TODO make this look like a key
			love.graphics.print(v, 380, 200 + k * rh)
		end
	end
	
	--draw assignments in locations
	for k,ua in pairs(unitAssignments) do
		if ua.count > 0 then 
			-- love.graphics.print(k, 100 * ua.count, 500)
			love.graphics.print(ua.name.." - "..ua.description, 600, ua.rowsAbove * rh)
			drawUnitIconsFromRIDListAt(ua.locations[1], 600, ua.rowsAbove * (rh+1))
		end
	end
end








function assignmentsKeyPressed(key)
	--TODO enable capital letters for auto-location-assignment
	--TODO enable space for auto-assignment (or skip/"back of the line"?)
	local activity = nil

	--did that key point to a real activity?
	for k,a in pairs(validActivities) do
		if a.key == key then
			activity = a
			break
		end
	end
	-- if not activity then return end
		
	-- tablePrint(activity)
	
	--TODO submenus for locations, etc
	if activity then
		if activity.outside then
			--TODO make player choose an outside area
			submenu1 = {
				label = "Select outside area:",
				activity = activity
			}
			
			--TODO only add to menu if there are appropriate goals for the activity in the area
			for k,v in ipairs(world) do
				submenu1[k] = v.name
			end
			
			print("submenu1")
			tablePrint(submenu1)
			
			-- assignUnitTo(unassignedIDs[1], activity.name)
			-- table.remove(unassignedIDs, 1)
		else
			--TODO make player choose a room TODO unless it doesn't require a room, like Dig
			print("pick a room:")
			tablePrint(activity.candidateRoomIDs)
		end
	end
	
	--submenu shit. kind of proof of concept for now
	if submenu1.label then --again, hacky. clean up later TODO
		if submenu1[tonumber(key)] then
			print("ping!")
			assignUnitTo(unassignedIDs[1], submenu1.activity.name)
			table.remove(unassignedIDs, 1)
			submenu1 = {}
		end
	end
	
	
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



function assignUnitTo(rosterIndex, activity, location)
	for k,ua in pairs(unitAssignments) do
		if ua.name == activity then
			table.insert(ua.locations[1], rosterIndex)--wrong TODO use actual locations, not just [1]
			ua.count = ua.count + 1
			print(rosterIndex..", "..roster[rosterIndex].name.." assigned to "..activity)
		end
	end
	
	--now adjust all rows; assume for now DEBUG that unassigned is unchanging
	local rowCount = 3 --like this
	for k,a in pairs(unitAssignments) do
		if a.count > 0 then
			a.rowsAbove = rowCount + 1
			rowCount = a.rowsAbove + math.ceil(a.count / 16) + 1
		end
	end
	
	-- tablePrint(unitAssignments)
end

-- function findDestinations(a)
-- 	d = {}
--
-- 	if a == "Train" then
-- 		d.space = world[1] --should always be foothills
--
-- 		--look at all rooms, finding Dojos
-- 		rn = 1 --"room number"
-- 		for k,r in pairs(mountain.rooms) do
-- 			if r.type == "Dojo" then
-- 				d[rn] = r
-- 				rn = rn + 1
-- 			end
-- 		end
-- 	end
--
-- 	return d
-- end


-- function drawAllUnits()
-- 	for k, v in pairs (roster) do
-- 		drawUnit(v, math.floor(k/20) * 150 + 10, 50 + (k % 20) * 20)
-- 	end
-- end