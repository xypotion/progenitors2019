--units with all empty slots should be white, units with no slots (pretty rare) should be black

require "assignments"
require "unit"

function love.load()
	math.randomseed(os.time())
	love.window.setMode(1200, 720)
	
	init13colors()
	
	love.graphics.setNewFont(20)
	
	--load images
	images = {
		-- Vulture = love.graphics.newImage("Vulture.png")
	}
	for k,v in pairs(speciesData) do
		images[k] = love.graphics.newImage(k..".png")
	end
	tablePrint(images)
	
	roster = {}
	roster[1] = initUnit("Vulture")
	
	for i = 2, 256 do 
		if math.random() > 0.5 then
			roster[i] = initUnit("Vulture", roster[i-1])
		else
			roster[i] = initUnit("Snake", roster[i-1])
		end
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