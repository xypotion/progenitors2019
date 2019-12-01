--object stack idea
-- all objects in stack are drawable (have a graphic), drawn in order. top = drawn last
-- all objects CAN have a click effect (a function call + parameters?)
-- all objects CAN have a hover effect (triggered in update, points to a function called at the end of draw; usually uses mouse pos automatically, but can draw elsewhere)
-- what about touch input? long-press to trigger hover? or tap? ugh
-- dragability... aargh

--you're overthinking it, right? or do all of these questions need to be answered now? so much infrastructure, so little fun :/
-- you are, a little bit! this version is supposed to be a hack. most basic playable form TO TEST THE DESIGN. not elegant and pretty
-- because making it super-elegant will take longer. if you put in all that work and THEN figured out that it's not fun, you'd be devastated.

--WELL, THIS DESIGN IS BASICALLY COMPLETELY DEFUNCT NOW. START OVER!

require "genome"
require "unit"

function love.load(args)
	love.window.setMode(800, 600)
	
	math.randomseed(os.time())
	
	fontBig = love.graphics.newFont(25)
	fontLittle = love.graphics.newFont(15)
	love.graphics.setFont(fontLittle)
	
	love.graphics.setLineWidth(2)
	
	-- phase = "newGame"--"assignments"--
	oscillator = 0
	glow = 1
	
	phaseTransition("newGame")
end

function love.draw()
	white()
	
	love.graphics.print(phase, 5, 5)
	
	_G[phase.."Draw"]()
end

function love.update(dt)
	oscillator = oscillator + dt * 5
	glow = math.cos(oscillator) / 2 + 0.5
	
	_G[phase.."Update"](dt)
end

function love.keypressed(key)
	if key == "escape" then love.event.quit() end

	_G[phase.."Keypressed"](key)
end

function love.mousepressed(x, y, button)
	_G[phase.."Mousepressed"](x, y, button)
end

function love.mousereleased(x, y, button)
	_G[phase.."Mousereleased"](x, y, button)
end

function phaseTransition(p)
	phase = p
	
	_G[phase.."Init"]()
end

-------------------------------------------------------------------------------------------------------------------------------

function newGameInit()
	mountainName = "Kailash "..math.random()
	
	--TODO so is this a system?
	--transgressions cause curses that pass down through generations and may summon avenging spirits in battle! curse = entire bottom row
	commandments = {
		-- {"Thou shalt not pray for children until thou art of age.", true}, --slightly arbitrary, esp. if starting age = "young adult"... TODO decide if needed
		{"Thou shalt not pray for children alongside thine own children.", true}, 
		{"Thou shalt not pray for children alongside thy siblings.", true}, 
		{"Thou shalt make no hole in my slopes.", false}, --no mining. 
		-- {"Thou shalt not exile a child of my slopes.", true}, --who gets punished if the *player* exiles a unit, though? darn.
		-- {"Thou shalt not eat the bodies of thy neighbors.", false}, --hard to implement! either dead units' meat is generic and this doesn't work, or it isn't and things get weird.
		{"Thou shalt worship no other before me.", false}, --praying anywhere besides mountain summit = transgression
		{"Thou shalt eat no flesh nor bone.", false}, --harsh but good
		-- {"Thou shalt allow no meat-eater to set foot upon my slopes.", false}, --needs to be clearer about whether it applies to omnivores or not TODO
		{"Thou shalt not befriend one who would do violence.", false}, --no recruiting in battle. could still be reworded (does it apply when enemies surrender?) TODO
		{"Thou shalt not turn away one seeking shelter.", false}, --affects unit(s) manning the gate. is this compatible with other commandments?
		{"Thou shalt make no tool nor weapon.", false}, --does this count armor? accessories? TODO
		{"Thou shalt not kill.", false}, --extremely harsh! would need to recruit all combatants, or let them surrender/retreat
	}
end

function newGameUpdate(dt)
	--cursor blink
end

function newGameDraw()	
	love.graphics.print("Name your mountain: "..mountainName, 100, 100)
end

--argh, why are you bothering!?
-- function love.textinput(t)
-- 	mountainName = mountainName .. t
-- end
--
function newGameKeypressed(key)
	if key == "return" then
		phaseTransition("progenitors")
	end
-- 	-- copied from https://love2d.org/wiki/love.textinput
--   if key == "backspace" then
--       -- get the byte offset to the last UTF-8 character in the string.
--       local byteoffset = utf8.offset(text, -1)
--
--       if byteoffset then
--           -- remove the last UTF-8 character.
--           -- string.sub operates on bytes rather than UTF-8 characters, so we couldn't do string.sub(text, 1, -2).
--           text = string.sub(text, 1, byteoffset - 1)
--       end
--   end
end

function newGameMousepressed(x, y, button)
end

function newGameMousereleased(x, y, button)
	phaseTransition("progenitors")
end

-------------------------------------------------------------------------------------------------------------------------------

function progenitorsInit()
	races = {"rabbit", "elephant", "deer", "squirrel", "grasshopper", "beaver"}
	candidates = {}
	roster = {}
	
	numSelected = 0
	wIncrementor = 0
	
	for i = 1, 6 do
		candidates[i] = generateProgenitor(races[i])
		-- print(races[i])
	end
	
	helpText = ""
	helpy = nil
end

function progenitorsUpdate(dt)
	--hover text stuff
	local x, y = love.mouse.getPosition()
	if y > 40 and y < 240 then
		if x > 25 and x < 775 then
			helpy = candidates[math.floor((x - 25) / 125) + 1]
			
			
			-- helpText = ""..c.name.."\n\n"..c.race.."\n\n"..c.cards.rx
		end
	end
end

function progenitorsDraw()
	-- love.graphics.print("PROGENITORS", 100, 100)
	
	for i = 1, 6 do
		drawUnitSmall(candidates[i], 40, i * 125 - 100)
	end
	
	--help text
	white()
	-- love.graphics.print(helpText, 50, 300)
	if helpy then
		drawCardSummary(helpy, 300, 50)
	end
	
	--accept button
	love.graphics.setColor(.8,.8,.8)
	love.graphics.rectangle("fill", 350, 500, 100, 50)
	
	love.graphics.setColor(0,0,0)
	love.graphics.print("Pick 3\nthen click", 355, 505)
end

function progenitorsKeypressed(key)
end

function progenitorsMousereleased(x, y, button)
	if x >= 350 and x <= 450 and y >= 500 and y <= 550 then
		if numSelected == 3 then
			for i = 1, 6 do
				if candidates[i].outlined then
					table.insert(roster, candidates[i])
				end
			end
			
			phaseTransition("roster")
		end
	end
	
	if y > 40 and y < 240 then
		if x > 25 and x < 775 then
			local n = math.floor((x - 25) / 125) + 1
			
			if candidates[n] then
				if candidates[n].outlined then
					numSelected = numSelected - 1
					candidates[n].outlined = false
				elseif not candidates[n].outlined then
					numSelected = numSelected + 1
					candidates[n].outlined = true
				end
			end
		end
	end
end

function progenitorsMousepressed(x, y, button)
	-- phaseTransition("roster")
end


-------------------------------------------------------------------------------------------------------------------------------

function rosterInit()
	population = table.getn(roster)
	selected = nil
end

function rosterUpdate(dt)
	local x, y = love.mouse.getPosition()
	
	if x < 150 and x > 50 then
		local yy = math.floor((y - 40) / 20)
		if yy > 0 and yy <= population then selected = yy end
	end
end

function rosterDraw()	
	for i = 1, population do
		love.graphics.print(roster[i].name, 50, 40 + 20 * i)
	end
	
	if selected then
		drawUnitSmall(roster[selected], 50, 200)
		
		--TODO, obviously
		love.graphics.print("(age)\n(racial bonus)\n(skills)\n(gear)\n(parents)", 350, 50)
	end
end

function rosterKeypressed(key)
end

function rosterMousepressed(x, y, button)
end

function rosterMousereleased(x, y, button)
	phaseTransition("invest")
end

-------------------------------------------------------------------------------------------------------------------------------

function investInit()
end

function investUpdate(dt)

end

function investDraw()
	love.graphics.print("The meat-eaters are coming... ", 100, 100)
end

function investKeypressed(key)
end

function investMousepressed(x, y, button)
end

function investMousereleased(x, y, button)
	phaseTransition("battle")
end

-------------------------------------------------------------------------------------------------------------------------------

function battleInit()
end

function battleUpdate(dt)

end

function battleDraw()
	love.graphics.print("battle", 100, 100)
end

function battleKeypressed(key)
end

function battleMousepressed(x, y, button)
end

function battleMousereleased(x, y, button)
	phaseTransition("aftermath")
end

-------------------------------------------------------------------------------------------------------------------------------

function aftermathInit()
end

function aftermathUpdate(dt)

end

function aftermathDraw()
	love.graphics.print("aftermath", 100, 100)
end

function aftermathKeypressed(key)
end

function aftermathMousepressed(x, y, button)
end

function aftermathMousereleased(x, y, button)
	phaseTransition("assignments")
end


-------------------------------------------------------------------------------------------------------------------------------

function assignmentsInit()
	wIncrementor = 0
	oscillator = 0
	glow = 1
	
	generateBlocks()
	
	--DEBUG
	if args and args[1] and args[2] then
		parent1 = generateParent(args[1])
		parent2 = generateParent(args[2])
	else
		parent1 = generateParent()
		parent2 = generateParent()
	end
	
	compatibility = findCompatibility(parent1, parent2)
	
	child = generateChild(parent1, parent2)
end

function assignmentsUpdate(dt)
	if moving then
		if counter > 0 then
			counter = counter - dt * 100
			-- print(counter)
		else
			--counter over! swap stuff
			counter = 0
			moving = false
			
			parent1 = child
			parent2 = newParent
			
			compatibility = findCompatibility(parent1, parent2)
			
			child = generateChild(parent1, parent2)
		end
	end
end

function assignmentsDraw()
	if moving then 
		drawUnit(child, 10 + counter, 10 + counter)
		drawUnit(newParent, 10 - counter, 410 - counter)
	else
		drawUnit(parent1, 10, 10)
		drawUnit(parent2, 10, 410)
		drawUnit(child, 210, 210)
		love.graphics.print("(compatibility = "..compatibility..")", 235, 100)
	end
end

function assignmentsKeypressed(key)
	if not moving then
		if key == "c" then child = generateChild(parent1, parent2) end
		
		if key == "q" then
			generateBlocks()
		end
	
		if key == "p" or key == "r" or key == "g" or key == "b" or key == "a" or key == "x" or key == "q" or key == "t" or key == "w" then
			moving = true
			counter = 200
			
			newParent = generateParent(key)
		end
	end
end

function assignmentsMousepressed(x, y, button)
end

function assignmentsMousereleased(x, y, button)
	phaseTransition("roster")
end


-------------------------------------------------------------------------------------------------------------------------------



-------------------------------------------------------------------------------------------------------------------------------



-------------------------------------------------------------------------------------------------------------------------------

function white()
	love.graphics.setColor(1,1,1)
end