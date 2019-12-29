function assignmentsDraw()
	--draw current unit summary, nice and big
	drawUnitSummary(roster[unassignedIDs[1]], 50, 50)
		
	drawUnassignedUnits()
	
	if STATE == "main" then
		drawActivitiesMenu()
		
		drawRoomAndAreaAssignments()
	elseif STATE == "select room" or STATE == "select area" then
		drawActivitiesMenu()
		drawLocationSubmenu()
	elseif STATE == "select mate" then
	elseif STATE == "something" then
	end
end

---------------------------------------------------------------------------------------------------

function drawUnassignedUnits()
	--draw unassigned unit icons
	love.graphics.print("Unassigned", 600, rh * 1)
	drawUnitIconsFromRIDListAt(unassignedIDs, 600, rh*1)
		
	love.graphics.print("Select activity for this unit this month:", rh, 5 * rh)
end

function drawActivitiesMenu()
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

---------------------------------------------------------------------------------------------------

function drawLocationSubmenu()
	love.graphics.print(submenu1.label, 300, 200)
	
	--TODO move this? or something? whole right side of the screen can be the submenu. 
	--will eventually have to make it a lot fancier than just a list of things
	
	for k,v in ipairs(submenu1) do
		drawKeyboardKey(k, rh * 9, (6 + k) * rh)
		love.graphics.print(v, rh * 10, (6 + k) * rh)
	end
end

---------------------------------------------------------------------------------------------------

function drawKeyboardKey(text, x, y)
	setColor(0.75,0.75,0.75)
	love.graphics.rectangle("fill", x + keyRectOffset, y + keyRectOffset, keyRectSize, keyRectSize)
	
	setColor(0,0,0)
	love.graphics.printf(" "..text, f2, x - keyRectOffset, y + keyRectOffset, rh, "center")
	
	white()
end

