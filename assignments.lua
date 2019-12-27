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

indoorAssigments
expeditions
other...

or requiresRoom = t/f, requiresDestination, requiresPartner

ugh, or just code them each individually? :/ it's not like there are that many

maybe the best question is how all assignments will be *displayed*.
- unassigned in a group
- indoor assignments: all rooms, then which units plan to use those rooms. icons for activities?
- expeditions: areas + units + activities

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
	rh = 34 --row height, in pixels
	
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
	--(is this actually necessary? TODO)
	validActivities = {}
	for k,a in pairs(activities) do
		-- print(a.name)
		
		--is it an "outside" activity?
		if a.outside then
			--TODO only add if there's a valid goal for this activity, e.g. a PoA somewhere to Investigate
			table.insert(validActivities, deepClone(a))
		else
			--if no, then check all rooms in mountain; find any valid ones for it? or is this an "always" activity? then add
			if a.validRooms or a.always then --slightly redundant TODO maybe refactor this whole block at some point
				local validActivityRoomTypes = a.validRooms or {} --a little janky but meh
				local validMountainRoomIDs = {}
				
				--are there any valid rooms for this activity?
				for i,r in pairs(mountain.rooms) do
					if tableContains(validActivityRoomTypes, r.type) then
						table.insert(validMountainRoomIDs, i)
					end
				end
				
				--if any valid rooms were found, add them to this activity clone, then add that to validActivities
				if validMountainRoomIDs[1] or a.always then
					local va = deepClone(a)
					va.candidateRoomIDs = deepClone(validMountainRoomIDs)
					table.insert(validActivities, va) 
				end
			end
		end
	end
	
	--initialize room-unit-assignment association table
	roomAssignments = {}
	for i, a in ipairs(mountain.rooms) do
		roomAssignments[i] = {}
	end
	
	tablePrint(roomAssignments)
	
	--and init similar for outside stuff (displayed separately)
	expeditions = {
		rowsAbove = 8,
		locations = deepClone(world)
	} 
	
	otherAssignments = {
		Dig = {},
		Idle = {}
	}

	--a bit janky, but let these cloney locations track their own assignees
	--actually TODO i don't like these being janky clones! clean that table up.
	for k,v in ipairs(expeditions.locations) do
		v.assignees = {}
	end

	calculateAssignmentRowCounts()
	
	submenu1 = {}
	submenu2 = {}
	
	-- tablePrint(roster[1])
end

function assignmentsUpdate(dt)
	-- TODO animations or something? lol
end

--takes a list of roster IDs, then draws them in a row starting at x,y; loops to new row every 16 units
function drawUnitIconsFromRIDListAt(ridList, xOffset, yOffset, activityNames)
	local miniIconOffset = rh/2
		
	for k, rid in ipairs(ridList) do
		local xPos = xOffset + ((k - 1) % 16 + 1) * rh
		local yPos = yOffset + math.floor((k - 1) / 16 + 1) * rh
		
		drawUnitIcon(roster[rid], xPos, yPos)
				
		if activityNames then
			local activityIcon = images[activityNames[k]]

			if activityIcon then --TODO checking for the icon should eventually not be necessary
				love.graphics.draw(activityIcon, xPos + miniIconOffset, yPos + miniIconOffset, 0, 0.125, 0.125)
			end
		end
	end
	
	white()
end 

function assignmentsDraw()
	--draw current unit summary, nice and big
	drawUnitSummary(roster[unassignedIDs[1]], 50, 50)
	
	white()
	
	--draw unassigned unit icons
	love.graphics.print("Unassigned", 600, rh * 1)
	drawUnitIconsFromRIDListAt(unassignedIDs, 600, rh*1)
		
	love.graphics.print("Select activity for this unit this month:", 50, 165)
	
	--draw activities menu
	for k, a in ipairs(validActivities) do
		--if are we also showing a submenu, make this one item yellow
		if submenu1.activityID == k then
			love.graphics.setColor(1,1,0)
		else
			white()
		end
		
		love.graphics.print(a.key, 50, 165 + k * rh) --TODO make this look like a key
		love.graphics.print(a.name, 80, 165 + k * rh)
	end
	
	white()
	
	--draw submenu1 if it's been populated
	if submenu1.label then --a little hacky, but should work, right? maybe reconsider later on TODO
		love.graphics.print(submenu1.label, 300, 200)
		
		for k,v in ipairs(submenu1) do
			love.graphics.print(k, 350, 200 + k * rh) --TODO make this look like a key
			love.graphics.print(v, 380, 200 + k * rh)
		end
	end
	
	--draw ROOMS, with their occupants & activities TODO
	love.graphics.print("Indoor Assignments:", 600, rh * 4)
	for i,r in ipairs(mountain.rooms) do --or should you loop over roomAssignments? could be cleaner, if that's a subset
		love.graphics.rectangle("line", 600 + rh, (i+4) * rh, rh*3, rh)
		love.graphics.print(r.name, 600 + rh*5, (i+4) * rh)
		
	
		--debug, kinda. this works but MUST be refactored. TODO
		local rids = {}
		local aNames = {}
		for k, ra in ipairs(roomAssignments[i]) do
			rids[k] = ra.rid
			aNames[k] = ra.aName
		end
		drawUnitIconsFromRIDListAt(rids, 600, (i+3) * rh, aNames)
	end
	
	--then draw expeditions if there are any pending
	if expeditions.locations[1] then
		local someExpeditions = false
				
		for i,el in ipairs(expeditions.locations) do
			if el.assignees[1] then --if there's at least one assignee
				--icon-scraping logic copy-pasted from rooms part above. again, must be refactored (because this is dumb) TODO
				local aNames = {}
				local rids = {}
				for k, ra in ipairs(el.assignees) do
					rids[k] = ra.rid
					aNames[k] = ra.aName
				end
				--draw assignees
				drawUnitIconsFromRIDListAt(rids, 600, (expeditions.rowsAbove+i-1) * rh, aNames)
				
				--also print the location name, as a label
				love.graphics.print(el.name, 600 + rh*8, (expeditions.rowsAbove+i) * rh)
			
				--and draw a little rectangle :)
				love.graphics.rectangle("line", 600 + rh, (expeditions.rowsAbove+i) * rh, 6*rh, rh)
				
				someExpeditions = true
			end
		end
		
		--print the expeditions section label if appropriate
		if someExpeditions then	
			love.graphics.print("Expeditions:", 600, expeditions.rowsAbove * rh)
		end
	end
end




function assignmentsKeyPressed(key)
	--TODO enable capital letters for auto-location-assignment
	--TODO enable space for auto-assignment (or skip/"back of the line"?)
	local selectedActivity = nil
	local selectedActivityID = nil

	--did that key point to a real activity?
	for k,a in pairs(validActivities) do
		if a.key == key then
			selectedActivity = a
			selectedActivityID = k
			break
		end
	end
	-- if not activity then return end
		
	-- tablePrint(activity)
	
	--TODO switch on submenu state (or something even better) so only one of these blocks happens
	--TODO generally clean up, refactor, move things out to other functions... as predicted, this function is getting super messy
	if selectedActivity then
		if selectedActivity.outside then
			--TODO make player choose an outside area
			submenu1 = {
				label = "Select an outside destination for this activity:",
				activity = selectedActivity,
				activityID = selectedActivityID
			}
			
			--TODO only add to menu if there are appropriate goals for the activity in the area? e.g. gathering points for Gather
			for k,v in ipairs(expeditions.locations) do
				submenu1[k] = v.name --TODO couldn't you just load the submenu with the objects and then print .names? refactoringgg
			end
		else
			--TODO make player choose a room TODO unless it doesn't require a room, like Dig
			print("pick a room:")
			tablePrint(selectedActivity.candidateRoomIDs)
			
			submenu1 = {
				label = "Select a room for this activity:",
				activity = selectedActivity,
				activityID = selectedActivityID
			}

			--add all rooms that have space...? TODO
			for k,v in ipairs(mountain.rooms) do
				submenu1[k] = v.name
			end
		end
			
		print("submenu1")
		tablePrint(submenu1)
	end
	
	--submenu shit. kind of proof of concept for now
	if submenu1.label then --again, hacky. clean up later TODO
		if submenu1[tonumber(key)] then -- yikes. TODO
			if submenu1.activity.outside then
				assignUnitToExpedition(unassignedIDs[1], submenu1.activity.name, tonumber(key))
			else
				assignUnitToIndoorActivity(unassignedIDs[1], submenu1.activity.name, tonumber(key))
			end
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

--TODO the whole expeditions table should be simpler. just use area IDs, not clones?
function assignUnitToExpedition(rosterIndex, activityName, areaID)
	table.insert(expeditions.locations[areaID].assignees, {rid = rosterIndex, aName = activityName})
	
	-- calculateAssignmentRowCounts()
	
	ping("expeds")
	tp(expeditions)
end

--TODO just split this into an indoor function and an outdoor function. much cleaner
function assignUnitToIndoorActivity(rosterIndex, activityName, roomID)	
	table.insert(roomAssignments[roomID], {rid = rosterIndex, aName = activityName})

	-- calculateAssignmentRowCounts()
	
	ping("rooms")
	tp(roomAssignments)
end

--just tells UA rows + expeditions where they should draw
--TODO put this function back together... unassigned, then rooms, then expeds, then idle/other?
function calculateAssignmentRowCounts()
	local rowCount = math.ceil(#unassignedIDs / 16) + 1
	local finalUARowCount = 0
	
	for k,a in pairs(roomAssignments) do
		finalUARowCount = rowCount + 1
	end
	
	--expeditions, last but not least
	expeditions.rowsAbove = 8 --DEBUG
	-- expeditions.rowsAbove = finalUARowCount
end