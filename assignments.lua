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
reset button
show assignment info (duration, description, cost)
for "expedition" assignments, show area info
+ add "goal" submenu
add mate submenu to Mate & stuff
show resources (should probably be universal)
mouse input...
actual assignement resolution...
--]]

require "assignmentsDraw"

function assignmentsStart()	
	rh = 34 --row height, in pixels
	keyRectOffset = 4
	keyRectSize = rh - keyRectOffset * 2
	miniIconOffset = rh/2	
	
	assignmentUndoStack = {}
	
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
	
	--FOR CONSISTENCY:
	--all of these "assignments" tables are lists of room IDs or area IDs (actually just straight-up clones of mountain.rooms and world)
	--NUMERIC members of those tables are pairs of other IDs: the roster ID (for the unit) and the activity ID, i.e. ASSIGNMENTS
		--...i hope this part doesn't bit me later. should be easy to add an "assignments" sub-table to each room/area list if needed
	
	--initialize room-unit-assignment association table. 
	--i waffled on whether or not this cloney approach was good, and i decided that it was. so don't worry about it.
	roomAssignments = deepClone(mountain.rooms)
	
	--and init similar for outside stuff (displayed separately)
	areaAssignments = deepClone(world)
		
	--and for things that don't require rooms/areas
	otherAssignments = {
		Dig = {drawAtY = 0},
		Idle = {} --TODO i dunno. do they need rooms to do this in or not? leaning yes, so maybe just make this a normal indoor activity
	}

	--where should things be drawn?
	calculateAssignmentRowCounts()
	
	--and submenus for later
	submenu1 = {}
	submenu2 = {}
	
	--trying this to keep menu input+draw logic a little more organized
	STATE = "main"
	--other valid STATEs: select room/area/mate/sort/product/structure, help/info, confirm assignments, etc
end

function assignmentsUpdate(dt)
	-- TODO animations or something? lol
end

function assignmentsKeyPressed(key)
	--undo or cancel
	if key == "backspace" then
		if STATE == "main" or STATE == "all assigned" then
			undoLastAssignment()
			
			calculateAssignmentRowCounts()
		elseif STATE == "select room" or STATE == "select area" then
			submenu1 = {}
			STATE = "main"
		elseif STATE == "select mate" then
			--might be harder than above. TODO
		end
	end
end

function assignmentsTextInput(key)
	processActivityDebugInput(key)
	
	if STATE == "main" then
		processActivityMainMenuInput(key)
	elseif STATE == "select room" or STATE == "select area" then
		processActivitySimpleSubmenuInput(key)
	elseif STATE == "select mate" then
	end
end
		
---------------------------------------------------------------------------------------------------
		
function processActivityMainMenuInput(key)
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
				
	--TODO generally clean up, refactor, move things out to other functions... as predicted, this function is getting super messy
	if selectedActivity then
		if selectedActivity.name == "Dig" then --sloppy but whatever. a lot of this is. maybe clean up later TODO
			assignUnitToOtherActivity(unassignedIDs[1], selectedActivity.name)
		elseif selectedActivity.outside then
			STATE = "select area"
			submenu1 = {
				label = "Select an outside destination for this activity:",
				activity = selectedActivity,
				activityID = selectedActivityID
			}
		
			--TODO only add to menu if there are appropriate goals for the activity in the area? e.g. gathering points for Gather
			for k,v in ipairs(areaAssignments) do
				submenu1[k] = world[k].name --TODO couldn't you just load the submenu with the objects and then print .names? refactoringgg
			end
			print("submenu1")
			tablePrint(submenu1)
		else
			--make player choose a room, unless it doesn't require a room, like Dig
			STATE = "select room"
			submenu1 = {
				label = "Select a room for this activity:",
				activity = selectedActivity,
				activityID = selectedActivityID
			}

			--add all rooms that have space...? TODO
			for k,v in ipairs(mountain.rooms) do
				submenu1[k] = v.name
			end
			print("submenu1")
			tablePrint(submenu1)
		end
	end
end

function processActivitySimpleSubmenuInput(key)
	if submenu1[tonumber(key)] then -- yikes. TODO
		if submenu1.activity.outside then
			-- ping("assigning?")
			assignUnitToExpedition(unassignedIDs[1], submenu1.activity.name, tonumber(key))
		else
			assignUnitToIndoorActivity(unassignedIDs[1], submenu1.activity.name, tonumber(key))
		end
		-- table.remove(unassignedIDs, 1)
		submenu1 = {}
		--hacky, but necessary. state management is not clean :/ TODO
		if STATE ~= "all assigned" then
			STATE = "main"
		end
	end
end
	
function processActivityDebugInput(key)
	--DEBUG shit
	if key == "\\" then
		print("\\ - all unassigned units assigned to Dig")
		local num = #unassignedIDs - 2
		for i = 1, num do
			assignUnitToOtherActivity(unassignedIDs[1], "Dig")
			-- table.remove(unassignedIDs, 1)
		end
		
		-- undoLastAssignment()
		
		calculateAssignmentRowCounts()
	end
	
	if key == "^" then
		print("^ - lighten all unit colors")
		for k,u in pairs(roster) do
			u.color[1] = 1 - ((1 - u.color[1]) / 1.5)
			u.color[2] = 1 - ((1 - u.color[2]) / 1.5)
			u.color[3] = 1 - ((1 - u.color[3]) / 1.5)
		end
	end
	
	if key == "%" then
		print("% - darken all unit colors")
		for k,u in pairs(roster) do
			u.color[1] = u.color[1] * 0.5
			u.color[2] = u.color[2] * 0.5
			u.color[3] = u.color[3] * 0.5
		end
	end
	
	if key == "&" then
		print("& - rotate all unit colors")
		for k,u in pairs(roster) do
			local temp = u.color[1]
			u.color[1] = u.color[2]
			u.color[2] = u.color[3]
			u.color[3] = temp
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
	
	if key == "*" then
		print("* - level up current unit")
		roster[unassignedIDs[1]].level = roster[unassignedIDs[1]].level + 1
		setUnitStatsByLevel(roster[unassignedIDs[1]])
	end
end

---------------------------------------------------------------------------------------------------

function assignUnitToExpedition(rosterIndex, activityName, areaID)
	table.insert(areaAssignments[areaID], {rid = rosterIndex, aName = activityName})
	
	calculateAssignmentRowCounts()
	
	--trace this in the undo stack
	table.insert(assignmentUndoStack, {
		f = "assignUnitToExpedition", 
		-- rosterIndex = rosterIndex, --wow, even this is not necessary?
		-- activityName = activityName, --i think not necessary?
		areaID = areaID,
		-- assignmentPos = table.getn(areaAssignments[areaID])  --also not necessary
	})
	
	vacateUnassignedIDs()
end

function assignUnitToIndoorActivity(rosterIndex, activityName, roomID)	
	table.insert(roomAssignments[roomID], {rid = rosterIndex, aName = activityName})

	calculateAssignmentRowCounts()
	
	table.insert(assignmentUndoStack, {
		f = "assignUnitToIndoorActivity", 
		roomID = roomID,
	})
	
	vacateUnassignedIDs()
end

function assignUnitToOtherActivity(rosterIndex, activityName)	
	table.insert(otherAssignments[activityName], {rid = rosterIndex, aName = activityName}) --redundant 9_9 ...don't care right now but TODO

	calculateAssignmentRowCounts()
	
	table.insert(assignmentUndoStack, {
		f = "assignUnitToOtherActivity", 
		activityName = activityName
	})
	
	vacateUnassignedIDs()
end

function vacateUnassignedIDs()
	table.remove(unassignedIDs, 1)
	
	if not unassignedIDs[1] then
		STATE = "all assigned"
	end
end

---------------------------------------------------------------------------------------------------

--you're making a lot of assumptions about where IDs will land in assignment tables. they're ALL simple stacks for now...
--fortunately, i don't think it will be hard to make these functions smarter later if necessary
function undoLastAssignment()
	ping()
	if not assignmentUndoStack[1] then
		print("nothing to undo, yo")
		return
	end
	
	local undoStep = stackPop(assignmentUndoStack)
	
	if undoStep.f == "assignUnitToExpedition" then
		--take last area asssignee and move them back to unassigned IDs
		-- undoStep.assignmentPos --maybe not needed, after all
		local undoneAssignment = table.remove(areaAssignments[undoStep.areaID])
		table.insert(unassignedIDs, 1, undoneAssignment.rid)
	elseif undoStep.f == "assignUnitToIndoorActivity" then
		local undoneAssignment = table.remove(roomAssignments[undoStep.roomID])
		table.insert(unassignedIDs, 1, undoneAssignment.rid)
	elseif undoStep.f == "assignUnitToOtherActivity" then
		local undoneAssignment = table.remove(otherAssignments[undoStep.activityName])
		table.insert(unassignedIDs, 1, undoneAssignment.rid)
	end
	
	--and recalc rows in case they need to shift
	calculateAssignmentRowCounts()
	
	--not sure if this is necessary outside of debugging, but allow state reset if you were previously at "all assigned"
	if unassignedIDs[1] then
		STATE = "main"
		ping()
	end
end

function redoLastUndoneAssignment()
	--TODO
end

---------------------------------------------------------------------------------------------------

--just tells different assignment sections where they should draw
--this function is sloppy and, in fact, buggy. rewrite at some point, please. TODO
function calculateAssignmentRowCounts()	
	local uRows = rowsNeededForNONLocationBasedAssignmentSection(unassignedIDs)
	local rRows = rowsNeededForLocationBasedAssignmentSection(roomAssignments)
	local aRows = rowsNeededForLocationBasedAssignmentSection(areaAssignments)
	local dRows = rowsNeededForNONLocationBasedAssignmentSection(otherAssignments.Dig)
	
	--unassignedIDs.drawAtY is not really a thing. just hard-coded at 1 for now
	
	roomAssignments.drawAtY = (uRows + 1) * rh
	
	areaAssignments.drawAtY = (uRows + rRows + 1) * rh
	
	otherAssignments.Dig.drawAtY = (uRows + rRows + aRows + 1) * rh
end

function rowsNeededForLocationBasedAssignmentSection(assignmentsList)
	local n = 0
	
	--count rows (each is a room or area)
	for k,v in ipairs(assignmentsList) do
		if v[1] then
			n = n + 1
		end
	end
	
	--for a title
	if n > 0 then n = n + 1 end
	
	return n
end

--there's still a bug here... TODO when dumping all but one unassigned units into Dig, this miscalculates the rows
function rowsNeededForNONLocationBasedAssignmentSection(assignmentsList)
	--count members in grid
	local n = math.ceil((table.getn(assignmentsList) - 1) / 16)
	
	--for a title
	if n > 0 then n = n + 1 end
	
	return n
end