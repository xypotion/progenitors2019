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
		Dig = {},
		Idle = {} --i guess. i dunno.
	}

	--where should things be drawn?
	calculateAssignmentRowCounts()
	
	--and submenus for later
	submenu1 = {}
	submenu2 = {}
end

function assignmentsUpdate(dt)
	-- TODO animations or something? lol
end

function assignmentsDraw()
	--draw current unit summary, nice and big
	drawUnitSummary(roster[unassignedIDs[1]], 50, 50)
	
	white()
	
	--draw unassigned unit icons
	love.graphics.print("Unassigned", 600, rh * 1)
	drawUnitIconsFromRIDListAt(unassignedIDs, 600, rh*1)
		
	love.graphics.print("Select activity for this unit this month:", rh, 5 * rh)
	
	--draw activities menu
	for k, a in ipairs(validActivities) do
		drawKeyboardKey(a.key, rh, 165 + k * rh)

		--if are we currently showing a submenu, make this one item yellow
		if submenu1.activityID == k then
			love.graphics.setColor(1,1,0)
		else
			white()
		end
		love.graphics.print(a.name, rh*2, 165 + k * rh)
	end
	
	white()
	
	--draw assignments OR submenu1 if it's been populated
	if submenu1.label then --a little hacky, but should work, right? maybe reconsider later on TODO
		love.graphics.print(submenu1.label, 300, 200)
		
		--TODO move this? or something? whole right side of the screen can be the submenu. 
		--will eventually have to make it a lot fancier than just a list of things
		
		for k,v in ipairs(submenu1) do
			drawKeyboardKey(k, rh * 9, (6 + k) * rh)
			love.graphics.print(v, rh * 10, (6 + k) * rh)
		end
	else
		drawRoomAndAreaAssignments()
	end
end

function drawKeyboardKey(text, x, y)
	setColor(0.75,0.75,0.75)
	love.graphics.rectangle("fill", x + keyRectOffset, y + keyRectOffset, keyRectSize, keyRectSize)
	
	setColor(0,0,0)
	love.graphics.printf(" "..text, f2, x - keyRectOffset, y + keyRectOffset, rh, "center")
	
	white()
end

function drawRoomAndAreaAssignments()
	--draw ROOMS with their occupants & activities
	local rowNumber = 0
			
	for i,room in ipairs(roomAssignments) do
		if room[1] then --if there's at least one assignee
			rowNumber = rowNumber + 1
			local yPos = rowNumber * rh + roomAssignments.drawAtY
			
			--draw assignees with icons
			drawUnitIconsFromAssignmentListAt(room, 600, yPos) 
			
			--also print the room name, as a label
			love.graphics.print(room.name, 600 + rh*8, yPos)
		
			--and draw a little rectangle :)
			love.graphics.rectangle("line", 600 + rh, yPos, room.capacity * rh, rh)
		end
	end
	
	--print the indoor assignments section label if appropriate
	if rowNumber > 0 then	
		love.graphics.print("Indoor Assignments:", 600, roomAssignments.drawAtY)
	end
	
	--then draw EXPEDITIONS if there are any pending
	rowNumber = 0
			
	for i,area in ipairs(areaAssignments) do
		if area[1] then --if there's at least one assignee
			rowNumber = rowNumber + 1
			local yPos = rowNumber * rh + areaAssignments.drawAtY
			
			--draw assignees with icons
			drawUnitIconsFromAssignmentListAt(area, 600, yPos)
			
			--also print the location name, as a label
			love.graphics.print(area.name, 600 + rh*8, yPos)
		
			--and draw a little rectangle!
			love.graphics.rectangle("line", 600 + rh, yPos, 6 * rh, rh)
		end
	end
	
	--print the expeditions section label if appropriate
	if rowNumber > 0 then	
		love.graphics.print("Expeditions:", 600, areaAssignments.drawAtY)
	end
	
	--TODO or TODONT: refactor this so one method draws both indoor and outdoor activities. will they always be so similar?
end

--takes a list of roster IDs, then draws them in a row starting at x,y; loops to new row every 16 units
function drawUnitIconsFromRIDListAt(ridList, xOffset, yOffset, activityNames)
	for k, rid in ipairs(ridList) do
		local xPos = xOffset + ((k - 1) % 16 + 1) * rh
		local yPos = yOffset + math.floor((k - 1) / 16 + 1) * rh

		drawUnitIcon(roster[rid], xPos, yPos)
	end

	white()
end

--takes a list of assignments (roster IDs + activity IDs), then draws them in a row starting at x,y
--the activity ID is for drawing an icon :)
function drawUnitIconsFromAssignmentListAt(assignmentList, xOffset, yOffset)	
	for k, assignment in ipairs(assignmentList) do
		local xPos = xOffset + k * rh
		local yPos = yOffset
		
		drawUnitIcon(roster[assignment.rid], xPos, yPos)
				
		if images[assignment.aName] then --TODO checking for the icon should eventually not be necessary
			love.graphics.draw(images[assignment.aName], xPos + miniIconOffset, yPos + miniIconOffset, 0, 0.125, 0.125)
		end
	end
	
	white()
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
			for k,v in ipairs(areaAssignments) do
				submenu1[k] = world[k].name --TODO couldn't you just load the submenu with the objects and then print .names? refactoringgg
			end
		else
			--TODO make player choose a room TODO unless it doesn't require a room, like Dig TODO
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
				-- ping("assigning?")
				assignUnitToExpedition(unassignedIDs[1], submenu1.activity.name, tonumber(key))
			else
				assignUnitToIndoorActivity(unassignedIDs[1], submenu1.activity.name, tonumber(key))
			end
			table.remove(unassignedIDs, 1)
			submenu1 = {}
		end
	end
	
	--undo
	if key == "backspace" then
		undoLastAssignment()
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
end

function assignUnitToIndoorActivity(rosterIndex, activityName, roomID)	
	table.insert(roomAssignments[roomID], {rid = rosterIndex, aName = activityName})

	calculateAssignmentRowCounts()
	
	table.insert(assignmentUndoStack, {
		f = "assignUnitToIndoorActivity", 
		roomID = roomID,
	})
end

--you're making a lot of assumptions about where IDs will land in assignment tables. they're ALL simple stacks for now...
--fortunately, i don't think it will be hard to make these functions smarter later if necessary
function undoLastAssignment()
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
	end
	
	--and recalc rows in case they need to shift
	calculateAssignmentRowCounts()
end

function redoLastUndoneAssignment()
	--TODO
end

--just tells different assignment sections where they should draw
function calculateAssignmentRowCounts()
	--unassigned is always at 0 (for now)
	
	--room assignments are below that
	roomAssignments.drawAtY = (math.ceil(#unassignedIDs / 16) + 2) * rh
	
	--and expeditions are below rooms
	areaAssignments.drawAtY = roomAssignments.drawAtY
	local someIndoors = false

	for k,room in ipairs(roomAssignments) do
		if room[1] then
			areaAssignments.drawAtY = areaAssignments.drawAtY + rh
			someIndoors = true
		end
	end
	
	--(add one more row if the indoor title will be drawn)
	if someIndoors then areaAssignments.drawAtY = areaAssignments.drawAtY + rh end
end