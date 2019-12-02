function assignmentsStart()	
	--index unassigned units
	unassigned = {}
	local i = 1
	for k,v in ipairs(roster) do
	  unassigned[i] = k
	  i = i + 1
	end
	-- tablePrint(unassigned)
	
	--activity menu 
	activities = {
		t = "Train",
		g = "Gather",
		d = "Dig",
		i = "Investigate",
		f = "Fast"
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
	drawUnit(roster[unassigned[1]], 100, 100)
	
	white()
	
	--draw unassigned unit icons
	love.graphics.print("Unassigned", 600, 48)
	for k, index in ipairs(unassigned) do
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
end

function assignmentsKeyPressed(key)
	--TODO enable capital letters

	--was this a valid activity?
	if activities[key] then
		table.remove(unassigned, 1)
		assignUnitTo(unassigned[1], activities[key])
	else
		print(key.." is not an activity we provide")
	end
	
	--TODO submenus for locations, etc
	
end




function assignUnitTo(cui, a)
	table.insert(unitAssignments[a], cui)
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



function drawAllUnits()	
	for k, v in pairs (roster) do
		drawUnit(v, math.floor(k/20) * 150 + 10, 50 + (k % 20) * 20)
	end
end