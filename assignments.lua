function assignmentsStart()
	ua = {} --"unit assignments"
	
	ui = 1--"unit index"
	
	activities = {
		t = "Train",
		g = "Gather",
		d = "Dig",
		i = "Investigate",
		f = "Fast"
	}
	tablePrint(activities)
	
	--find all destinations
	allDestinations = {}
	for k,a in pairs(activities) do
		allDestinations[a] = findDestinations(a)
	end
	
	tablePrint(allDestinations)
end

function assignmentsUpdate(dt)
end

function assignmentsDraw()
	drawUnit(roster[ui], 100, 100)
	
	white()
	
	--draw activities menu
	local i = 0
	for k,a in pairs(activities) do
		love.graphics.print(k, 100, 200 + i * 30)
		love.graphics.print(a, 130, 200 + i * 30)
		i = i + 1
	end
	
	--debug. draw all Train destinations
	i = 0
	for k,d in pairs(allDestinations.Train) do
		love.graphics.print(k, 300, 200 + i * 30)
		love.graphics.print(d.uniqueName, 350, 200 + i * 30)
		i = i + 1
	end
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