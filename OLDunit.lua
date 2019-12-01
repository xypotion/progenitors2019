function generateUnit(parents, race)
	if parents then 
		--generateChild() i guess, but that'd have to be rewritten
	else
		if race then
			--generate a progenitor!!
			return generateProgenitor(race)
		else
			print("that's not how you generate a unit. need parents or a race!")
		end
	end
end

--basically generate a child but without parents
function generateProgenitor(race)
	local u = {
		race = race,
		name = randomName(),
		outlined = false
	}

	--generate genome with either r, g, or b leaning
	local g = {}
	local r = {"r", "g", "b"}
	r = r[math.random(3)]
	for y = 1, 9 do
		g[y] = {}
		for x = 1, 6 do			
			g[y][x] = {generateGene(r), generateGene(r)}
		end
	end
	
	u.genome = g
	u.cards = countCards(u.genome)
	u.cardList = generateCardList(u.cards)
	
	return u
end



function drawUnitSmall(u, yo, xo)
	for y = 1, 9 do
		for x = 1, 6 do
			local m = u.genome[y][x][1]
			local n = u.genome[y][x][2]
			
			setGeneColor(m)
			-- love.graphics.rectangle("fill", xOffset + x * 12 + 0, yOffset + y * 12 + 20, 4, 9)
			love.graphics.polygon("fill", xo + x * 15, yo + y * 12, xo + x * 15 + 10, yo + y * 12, xo + x * 15, yo + y * 12 + 10)
			setGeneColor(n)
			-- love.graphics.rectangle("fill", xOffset + x * 12 + 5, yOffset + y * 12 + 20, 4, 9)
			love.graphics.polygon("fill", xo + x * 15 + 10, yo + y * 12 + 10, xo + x * 15 + 10, yo + y * 12, xo + x * 15, yo + y * 12 + 10)
	
			--glowing box
			if m == n and m ~= 0 then
				love.graphics.setColor(1, 1, 1, glow)
				love.graphics.rectangle("line", xo + x * 15 + 0, yo + y * 12 + 0, 10, 10)
			end
		end
	end
	
	--labels
	white()
	love.graphics.print(u.name, xo + 5, yo + 125)
	
	love.graphics.print(u.race, xo + 5, yo + 150)
	
	--outline? this is a bad place for this but... hacking...
	if u.outlined then
		love.graphics.rectangle("line", xo, yo, 120, 200)
	end
end



function drawCardSummary(u, yO, xO)
	--common cards
	--no. love.graphics.print({{1,0,0}, u.counts.r, {1,1,1}, ", ", {0,1,0}, u.counts.g, {1,1,1}, ", ", {0,0,1}, u.counts.b, {1,1,1}, ", "..u.counts.a}, xO, yO)
	love.graphics.print(u.cardList, xO, yO)
	
	--any rare cards
	
	--not sure what to do with RG, RB, GB yet! TODO
	
	--racial bonus? that's another chunk of info that needs to be stored somewhere TODO
end


--obviously this can be more efficient. TODO
function randomName()
	local names = {"Ton-ton", "Bertha", "Sormtnin", "Blue", "Tamara", "Axel", "Hee", "Kissy", "Justine", "Crange", "Ziggy", "Norp", "Winter", "Fana", "Peh", "Moon", "Sailee"} --it really doesn't matter right now
	return names[math.random(#names)]
end