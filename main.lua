--units with all empty slots should be white, units with no slots (pretty rare) should be black

require "assignments"
require "unit"
require "activityData"

function love.load()
	math.randomseed(os.time())
	love.window.setMode(1200, 720)
	
	crazyColor = {0.5, 0.5, 0.5}
	
	love.graphics.setPointSize(2.5)
		
	f1 = love.graphics.setNewFont(24)
	f2 = love.graphics.newFont(10)
	
	--load images
	images = {
		-- Vulture = love.graphics.newImage("Vulture.png")
		Medal1 = love.graphics.newImage("Medal1.png"),
		Medal2 = love.graphics.newImage("Medal2.png"),
		Medal3 = love.graphics.newImage("Medal3.png"),
	}
	for k,v in pairs(speciesData) do
		images[k] = love.graphics.newImage(k..".png")
	end

	--who's your progenitor?
	roster = {}
	-- roster[1] = initUnit("Ant")
	-- roster[1] = initUnit("Elephant")
	roster[1] = initUnit(randomSpecies())
		
	for i = 2, 25 do 
		-- roster[i] = initUnit("Snake")
		-- roster[i] = initUnit("Elephant")
		roster[i] = initUnit(randomSpecies(), roster[i-1])
	end
	-- tablePrint(roster)
	
	-- roster[3] = deepClone(roster[1])--debug
	-- roster[5] = deepClone(roster[1])--debug
	
	findHighestStatsAmongLivingUnits()
	
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
	--debug?
	-- crazyColor[1] = 1 % (crazyColor[1])-- + math.random() / 1)
	-- print(crazyColor[1])
	crazyColor[1] = math.random() + glow
	crazyColor[2] = math.random() + glow
	crazyColor[3] = math.random() + glow

	
	--these will return!
	oscillator = oscillator + dt * 5
	glow = math.cos(oscillator) / 2 --+ 0.5
	
	_G[phase.."Update"](dt)
end

function love.draw()	
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






function findHighestStatsAmongLivingUnits()
	--looping multiple times is inefficient, but the most elegant way to do this is currently beyond me!
	local statNames = {"maxHP", "int", "str", "agl"}
	local bigWinners = {}
	
	--find the big winners
	for i,sn in pairs(statNames) do
		local winners = {0, 0, 0}
		
		for j,unit in pairs(roster) do
			local stat = unit.stats[sn]
			
			if stat ~= winners[1] and stat ~= winners [2] and stat ~= winners[3] then
				if stat > winners[3] then
					winners[3] = stat
				end
			
				if stat > winners[2] then
					local swap = winners[2]
					winners[2] = stat
					winners[3] = swap
				end			
			
				if stat > winners[1] then
					local swap = winners[1]
					winners[1] = stat
					winners[2] = swap
				end
			end
		end
		
		bigWinners[sn] = deepClone(winners)
	end
		
	--then find, like, the BIG WINNERS
	for i,unit in pairs(roster) do
		unit.medals = {}
		
		for j,sn in pairs(statNames) do
			for medalNumber = 1, 3 do
				if unit.stats[sn] == bigWinners[sn][medalNumber] then
					unit.medals[sn] = medalNumber
					
					--because apparently you have to do this... for some reason...
					if not unit.bestMedal or medalNumber < unit.bestMedal then
						unit.bestMedal = medalNumber
					end
				end
			end
		end
		
		-- print(i, unit.name)
		-- tablePrint(unit.medals)
	end
end






function initMountain()
	local m = {}
	
	m.rooms = {
		initRoom("Entry"),
		initRoom("Residence"),
		initRoom("Storage"),
	}
	
	return m
end

function initRoom(type)
	if not type then type = "empty" end
		
	r = {}
	r.type = type
	r.name = type.." "..(os.time() % 1000)
	r.capacity = 3
	print(r.name)
		
	return r
end







function initWorld()
	local w = {}
	
	w[1] = initArea("Foothills", 1)
	w[2] = initArea("Forest", 1)
	
	return w
end

function initArea(type, level)
	if not type or not areaData[type] then type = "BLANK" end
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
	
	a.name = a.type.." "..(os.time() % 1000) --aka uniqueName
	
	return a
end

areaData = {
	BLANK = {
		resources = {},
		rewards = {},
		hazards = {},
		enemies = {}
	},
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

function tableContains(table, item)
	for k,v in pairs(table) do
		if item == v then return true end
	end
	
	return false
end

function tp(a, b)
	tablePrint(a, b)
end

function ping(text)
	if not text then text = "ping!" end
	
	print(text)
end

function setColor(r,g,b,a)
	love.graphics.setColor(r,g,b,a)
end