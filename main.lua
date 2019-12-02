--units with all empty slots should be white, units with no slots (pretty rare) should be black

require "assignments"

function love.load()
	math.randomseed(os.time())
	love.window.setMode(1200, 720)
	
	init13colors()
	
	love.graphics.setNewFont(20)
	
	--load images
	images = {
		Vulture = love.graphics.newImage("Vulture.png")
	}
	-- tablePrint(images)
	
	roster = {}
	roster[1] = initUnit("Vulture")
	
	for i = 2, 256 do 
		roster[i] = initUnit("Vulture", roster[i-1])
	end
	-- tablePrint(roster)
	
	
	-- roster[1] = initUnit("foo")
	-- print(roster[1].name)
	
	mountain = initMountain()
	-- tablePrint(mountain)
	
	world = initWorld()
	-- tablePrint(world)
	
	phase = "assignments"--"newGame"--
	oscillator = 0
	glow = 1
	
	assignmentsStart()
end

function love.update(dt)
	oscillator = oscillator + dt * 5
	glow = math.cos(oscillator) / 2 + 0.5
	
	_G[phase.."Update"](dt)
end

function love.draw()
	-- draw13colors()

	white()
	
	love.graphics.print(phase, 5, 5)
	
	_G[phase.."Draw"]()
	
	--draw unit 1
	-- drawUnit(roster[1], 100, 300)
end

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	end
	
	_G[phase.."KeyPressed"](key)
end





function initUnit(species, parent)
	local u = {}
	u.species = species
	u.stats = deepClone(speciesData[species].stats)
	
	if parent then
		u.name = generateName(parent.name)
	else
		u.name = generateName()
	end
	
	if parent then
		u.genome = initGenome(parent.genome)
	else
		u.genome = initGenome()
	end
	u.color = unitColorByGenome(u.genome)
	
	return u
end

speciesData = {
	foo = {
		stats = {
			maxHP = 10,
			int = 10,
			str = 10,
			agl = 10
		}
	},
	Vulture = {
		stats = {
			maxHP = 30,
			int = 40,
			str = 10,
			agl = 20
		}
	}
}

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

triangleMesh = love.graphics.newMesh({{0,-1},{5,-16},{-5,-16}}, "fan", "static")
piOver3 = math.pi / 3

function drawUnit(u, xOffset, yOffset)
	--print name
	love.graphics.print(u.name, xOffset, yOffset)
	
	--draw image
	love.graphics.setColor(u.color)
	love.graphics.draw(images[u.species], xOffset, yOffset + 20, 0, 0.5, 0.5)
	-- love.graphics.draw(images[u.species], xOffset + 100, yOffset + 20, 0, 0.25, 0.25)
	
	--draw genome
	drawGenome(u.genome, xOffset + 200, yOffset - 50)
end

function drawUnitIcon(u, xOffset, yOffset)
	love.graphics.setColor(u.color)
	love.graphics.draw(images[u.species], xOffset, yOffset, 0, 0.25, 0.25)
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

function unitColorByGenome(g)
	local c = {1,1,1}
	local counts = {R = 0, G = 0, B = 0}
	
	for k,v in pairs(g) do
		counts[v] = counts[v] + 1
	end
	
	-- tablePrint(counts)
	
	local min, mult = -0.75, 3
	c[1] = min + mult * counts.R / (counts.G + counts.B)
	c[2] = min + mult * counts.G / (counts.R + counts.B)
	c[3] = min + mult * counts.B / (counts.R + counts.G)
	
	return c
end

function generateName(pn)
	if pn ~= nil and string.len(pn) < 4 + math.random(8) then
		return generateNameFromParentName(pn)
	end
	
	local bits = {
		"an", "be", "cin", "der", "e'o", "fe", "gla", "hia", "is", "ja", "kou", "len", "mae", 
		"nor", "o'o", "pia", "qua", "res", "sey", "tui", "un", "ver", "wei", "x'ru", "yem", "zem"
	}
	local numbits = 26
	
	local n = bits[math.random(numbits)]
	local i = 1
	local j = 1
	
	while i > 3/4 and j <= 4 do
		n = n..bits[math.random(numbits)]
	
		i = math.random()
		j = j + 1
	end
	
	n = firstToUpper(n)
	
	return n
end

function generateNameFromParentName(pn)
	local bits = {
		"aya", "bel", "cah", "dya", "em", "fi", "go", "hest", "in", "je'o", "kel", "lal", "mem", 
		"nale", "onda", "ped", "qu", "ra", "sep", "tot", "uwo", "vay", "wa", "xi", "yaha", "zu"
	}
	local numbits = 26
	
	local suffix = bits[math.random(numbits)]
	
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
				
	n = n.."-"..suffix
	n = firstToUpper(n)
	
	return n
end




function initMountain()
	local m = {}
	
	m.rooms = {
		initRoom("entrance"),
		initRoom(),
		initRoom(),
	}
	
	return m
end

function initRoom(type)
	if not type then type = "storage" end
		
	r = {}
	r.type = type
	r.uniqueName = type.." "..os.time()
		
	return r
end







function initWorld()
	local w = {}
	
	w[1] = initArea("Foothills", 1)
	
	return w
end

function initArea(type, level)
	if not type then type = "blank" end
	if not level then level = 1 end
	
	local a = deepClone(areaData[type])
	a.rand = 1 + math.random()
	a.type = type
	a.level = level * a.rand
	
	--apply level multipliers, initialize progress levels
	for k,v in pairs(a.resources) do
		if v.obf then
			v.progress = 0
			v.obf = round(v.obf * a.rand)
		end
		
		--also augment abundance by rand
		v.abn = round(v.abn * a.rand)
	end
	
	for k,v in pairs(a.rewards) do
		if v.obf then
			v.progress = 0
			v.obf = round(v.obf * a.rand)
		end
	end
	
	a.uniqueName = a.type.." "..a.rand
	
	return a
end

areaData = {
	Foothills = {
		resources = {
			{type = "foliage", abn = 1},
			{type = "wood", abn = 1, obf = 5}, --abundance, obfuscation
		},
		rewards = {
			{type = "fairy", obf = 5},
			{type = "road", obf = 20}, --this type is randomly determined when the road is uncovered!
		},
		hazards = {},
		enemies = {}
	},
}

-- copied from https://stackoverflow.com/questions/2421695/first-character-uppercase-lua
function firstToUpper(str)
    return (str:gsub("^%l", string.upper))
end

function white()
	love.graphics.setColor(1,1,1)
end

function round(n)
	if n % 1 >= 0.5 then
		return math.ceil(n)
	else
		return math.floor(n)
	end
end

--assumes that tables are never used as KEYS in t, only as values
function deepClone(t)
	if type(t) ~= "table" then 
		print("that's not a table! can't clone it") 
		return t
	else
		local clone = {}
		
		for k,v in pairs(t) do
			if type(v) == "table" then
				clone[k] = deepClone(v)
			else
				clone[k] = v
			end
		end
	
		return clone
	end
end

--ye olde helper function
function tablePrint(table, offset)
	offset = offset or "  "
	
	for k,v in pairs(table) do
		if type(v) == "table" then
			print(offset.."sub-table ["..k.."]:")
			tablePrint(v, offset.."  ")
		else
			print(offset.."["..k.."] = "..tostring(v))
		end
	end	
end

--just experimenting with 13 unit colors, to start

function init13colors()
	h = 0.9
	m = 0.6
	l = 0.3
	
	thirteenColors = {
		{h, l, l},
		{l, h, h},
		{l, h, l},
		{h, l, h},
		{l, l, h},
		{h, h, l},
		
		{h, m, l},
		{h, l, m},
		{m, h, l},
		{m, l, h},
		{l, h, m},
		{l, m, h},

		{h, h, h},
		-- {l, l, l},
		-- {m, m, m},
		--
		-- {h, l, l},
		-- {l, m, m},
		-- {l, h, l},
		-- {m, l, m},
		-- {l, l, h},
		-- {m, m, l},
		--
		-- {h, m, m},
		-- {l, m, m},
		-- {m, h, m},
		-- {m, l, m},
		-- {m, m, h},
		-- {m, m, l},
		--
		-- {m, l, l},
		-- {m, h, h},
		-- {l, m, l},
		-- {h, m, h},
		-- {l, l, m},
		-- {h, h, m},
	}
end

function draw13colors()
	for i = 1, 13 do
		local x = (i - 1) % 6
		local y = math.ceil(i / 6)
		
		love.graphics.setColor(thirteenColors[i])
		
		love.graphics.rectangle("fill", 60 + x*50, 10 + y*50, 40, 40)
	end	
	-- love.setColor
	
	love.graphics.setColor(1,0,0)
	love.graphics.print("these", 60, 250)
	love.graphics.setColor(1,1,0)
	love.graphics.print("bold", 60, 260)
	love.graphics.setColor(0,1,0)
	love.graphics.print("colors", 60, 270)
	love.graphics.setColor(0,1,1)
	love.graphics.print("don't", 60, 280)
	love.graphics.setColor(0,0,1)
	love.graphics.print("really", 60, 290)
	love.graphics.setColor(1,0,1)
	love.graphics.print("occur", 60, 300)
end