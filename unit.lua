require "speciesData"

nameBits = {
	original = {
		main = {"an", "be", "cin", "der", "e'o", "fe", "gla", "hia", "is", "ja", "kou", "len", "mae", 
			"nor", "o'o", "pia", "qua", "res", "sey", "tui", "un", "ver", "wei", "x'ru", "yem", "zem"},
		suffixes = {"aya", "bel", "cah", "dya", "em", "fi", "go", "hest", "in", "je'o", "kel", "lal", "mem", 
			"nale", "onda", "ped", "qu", "ra", "sep", "tot", "uwo", "vay", "wa", "xi", "yaha", "zu"},
		punctuator = "-"
	},
	new = {
		main = {"ay", "bel", "cha", "da", "ex", "for", "gon", "haw", "ia", "jia", "kit", "lo", "mor",
			"niz", "ot", "pa", "quin", "ro", "sha", "teo", "unu", "vu", "wil", "xa", "ya", "zes"},
		suffixes = {},
		punctuator = "'"
	}
}

function initUnit(species, parent)
	local u = {}
	u.species = species

	
	u.maxLevel = math.random(36)
	u.level = 36 --DEBUG! math.random(u.maxLevel)
	
	u.stats = {}--deepClone(speciesData[species].stats)
	for k,v in pairs(speciesData[species].stats) do
		u.stats[k] = v * speciesBaseStatMultiplier * u.level
	end
	
	if parent then
		u.name = generateName(parent.name)
		-- u.name = generateNameFromParentName(parent.name) --this is called inside generateName(). don't call it here.
	else
		u.name = generateName()
	end
	
	if parent then
		u.genome = initGenome(parent.genome)
	else
		u.genome = initGenome()
	end
	
	tallyStatsFromGenome(u)
	
	u.color = unitColorByGenome(u.genome)
	
	return u
end

function initGenome(pg)
	local g = {}
	local alleles = {"R", "G", "B"}
	for i = 1, 54 do
		if pg and math.random() > 0.5 then
			g[i] = pg[i]			
		else
			g[i] = alleles[math.random(3)]
		end
	end
	
	return g
end

function unitColorByGenome(g)
	local c = {1,1,1}
	local counts = {R = 0, G = 0, B = 0}
	
	for k,v in pairs(g) do
		counts[v] = counts[v] + 1
	end
	
	-- tablePrint(counts)
	
	local min, mult = -0.666, 2.66 --very good
	-- local min, mult = -0.666, 2.75 --also very good
	-- local min, mult = -0.75, 3 --decent
	-- local min, mult = -0.666, 3
	-- local min, mult = -1, 4
	c[1] = min + mult * counts.R / (counts.G + counts.B)
	c[2] = min + mult * counts.G / (counts.R + counts.B)
	c[3] = min + mult * counts.B / (counts.R + counts.G)
	
	return c
end

function generateName(pn)
	if pn ~= nil and string.len(pn) < 4 + math.random(8) then
		return generateNameFromParentName(pn)
	end
	
	-- local bits = nameBits.original
	local bits = nameBits.new
	local numbits = 26
	
	local n = bits.main[math.random(numbits)]
	local i = 1
	local j = 1
	
	while i > 3/4 and j <= 4 do
		n = n..bits.main[math.random(numbits)]
	
		i = math.random()
		j = j + 1
	end
	
	n = firstToUpper(n)
	
	-- print(n)
	return n
end

function generateNameFromParentName(pn)
	local bits = nameBits.original
	local numbits = 26
	
	local suffix = bits.suffixes[math.random(numbits)]
	
	-- local n = pn:sub(3)
	--get parent's name without the '-'
	local n = pn
	local t = {}
	for str in string.gmatch(pn, "([^-]+)") do
		table.insert(t, str)
	end
	if t[2] then
		n = t[1]..t[2]
	else
		n = t[1]
	end
				
	n = n..bits.punctuator..suffix
	n = firstToUpper(n)
	
	-- print(n)
	return n
end

function tallyStatsFromGenome(u)
	local previous = u.genome[54]
	local incrementor = 1/3 * u.level
	
	--tally them up
	for i,v in ipairs(u.genome) do
		if v == previous then
			if v == "R" then
				u.stats.int = u.stats.int + incrementor
			elseif v == "G" then
				u.stats.str = u.stats.str + incrementor
			elseif v == "B" then
				u.stats.agl = u.stats.agl + incrementor
			end
		else
			u.stats.maxHP = u.stats.maxHP + incrementor
		end
		
		previous = v
	end
	
	--and round them off
	for k,v in pairs(u.stats) do
		u.stats[k] = round(v)
	end
end

--------------------------------------------------------------------------------------------------

triangleMesh = love.graphics.newMesh({{0,-1},{5,-16},{-5,-16}}, "fan", "static")
piOver3 = math.pi / 3

function drawUnitSummary(u, xOffset, yOffset)
	--draw image
	love.graphics.setColor(u.color)
	love.graphics.draw(images[u.species], xOffset, yOffset, 0, 0.5, 0.5)
	
	white()
	
	--print name
	love.graphics.print("\n\n\n"..u.name, xOffset + 5, yOffset)
	
	--print level
	love.graphics.print("Level\n"..u.level.."/"..u.maxLevel, xOffset + 100, yOffset)
	
	--print stats
	love.graphics.print("HP\nINT\nSTR\nAGL", xOffset + 180, yOffset)
	love.graphics.print(u.stats.maxHP.."\n"..u.stats.int.."\n"..u.stats.str.."\n"..u.stats.agl, xOffset + 240, yOffset)
	
	--show stat medals... you dork
	if u.medals then
		if u.medals.maxHP then
			love.graphics.draw(images["Medal"..u.medals.maxHP], xOffset + 162, yOffset + 4, 0, 0.125, 0.125)
		end

		if u.medals.int then
			love.graphics.draw(images["Medal"..u.medals.int], xOffset + 162, yOffset + 27, 0, 0.125, 0.125)
		end

		if u.medals.str then
			love.graphics.draw(images["Medal"..u.medals.str], xOffset + 162, yOffset + 50, 0, 0.125, 0.125)
		end

		if u.medals.agl then
			love.graphics.draw(images["Medal"..u.medals.agl], xOffset + 162, yOffset + 73, 0, 0.125, 0.125)
		end
	end
	
	--draw genome
	drawGenome(u.genome, xOffset + 300, yOffset - 50)
	
	white()
end

function drawUnitIcon(u, xOffset, yOffset)
	love.graphics.setColor(u.color)
	love.graphics.draw(images[u.species], xOffset, yOffset, 0, 0.25, 0.25)
	
	-- --eyes
	-- ok, this proof of concept works. do it better, though TODO
	-- if speciesData[u.species].eyes then
	-- 	love.graphics.setColor(crazyColor)
	-- 	-- print("ping")
	-- 	-- love.graphics.points(9,9)
	-- 	love.graphics.points(speciesData[u.species].eyes[1] * 2 + xOffset - 1, speciesData[u.species].eyes[2] * 2 + yOffset - 1)
	-- end
	
	white() 
	
	--got any medals?
	if u.bestMedal then
		love.graphics.draw(images["Medal"..u.bestMedal], xOffset + 16, yOffset, 0, 0.125, 0.125)
	end
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

function drawGenome(g, xOffset, yOffset)
	for k,v in pairs(g) do
		if v == "R" then
			love.graphics.setColor(1,0.25,0.25)
		elseif v == "G" then
			love.graphics.setColor(0.25,1,0.25)
		elseif v == "B" then
			love.graphics.setColor(0.25,0.25,1)
		end
		
		local i = k - 1
		local x = xOffset + 50 + math.floor(i / 6) % 3 * 40
		local y = yOffset + 50 + math.floor(i / 18) * 40 
		local r = piOver3 * (i % 6)
		
		love.graphics.draw(triangleMesh, x, y, r)
	end
end
