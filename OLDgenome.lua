
function generateCardList(cards)
	-- local cards = {rx = 0, gx = 0, bx = 0, rg = 0, rb = 0, gb = 0, rr = 0, gg = 0, bb = 0}
	-- local list = "cards:\n"
	--
	-- if cards.rx > 0 then list = list.."RX - "..cards.rx.."\n" end
	-- if cards.gx > 0 then list = list.."GX - "..cards.gx.."\n" end
	-- if cards.bx > 0 then list = list.."BX - "..cards.bx.."\n" end
	-- if cards.rg > 0 then list = list.."RG - "..cards.rg.."\n" end
	-- if cards.rb > 0 then list = list.."RB - "..cards.rb.."\n" end
	-- if cards.gb > 0 then list = list.."GB - "..cards.gb.."\n" end
	-- if cards.rr > 0 then list = list.."RR - "..cards.rr.."\n" end
	-- if cards.gg > 0 then list = list.."GG - "..cards.gg.."\n" end
	-- if cards.bb > 0 then list = list.."BB - "..cards.bb.."\n" end
	-- if cards.xx > 0 then list = list.."XX - "..cards.xx.."\n" end
	
	local list = {}--{1,1,1}, "cards:\n"}
	
	-- if cards.rx > 0 then table.insert(list, {1,0,0}) table.insert(list, "RX - "..cards.rx.."\n") end
	-- if cards.gx > 0 then table.insert(list, {0,1,0}) table.insert(list, "GX - "..cards.gx.."\n") end
	-- if cards.bx > 0 then table.insert(list, {0,0,1}) table.insert(list, "BX - "..cards.bx.."\n") end
	--  	if cards.rg > 0 then table.insert(list, {1,1,0}) table.insert(list, "RG - "..cards.rg.."\n") end
	--  	if cards.rb > 0 then table.insert(list, {1,0,1}) table.insert(list, "RB - "..cards.rb.."\n") end
	--  	if cards.gb > 0 then table.insert(list, {0,1,1}) table.insert(list, "GB - "..cards.gb.."\n") end
	--  	if cards.rr > 0 then table.insert(list, {1,0,0}) table.insert(list, "*** RR - "..cards.rr.."\n") end
	--  	if cards.gg > 0 then table.insert(list, {0,1,0}) table.insert(list, "*** GG - "..cards.gg.."\n") end
	--  	if cards.bb > 0 then table.insert(list, {0,0,1}) table.insert(list, "*** BB - "..cards.bb.."\n") end
	--  	if cards.xx > 0 then table.insert(list, {1,1,1}) table.insert(list, "XX - "..cards.xx.."\n") end

	if cards.rx > 0 then table.insert(list, {1,0,0}) table.insert(list, "RX - "..cards.rx.."\n") end
	if cards.gx > 0 then table.insert(list, {0,1,0}) table.insert(list, "GX - "..cards.gx.."\n") end
	if cards.bx > 0 then table.insert(list, {0,0,1}) table.insert(list, "BX - "..cards.bx.."\n") end
 	-- if cards.rg > 0 then table.insert(list, {1,1,0}) table.insert(list, "RG - "..cards.rg.."\n") end
 	-- if cards.rb > 0 then table.insert(list, {1,0,1}) table.insert(list, "RB - "..cards.rb.."\n") end
 	-- if cards.gb > 0 then table.insert(list, {0,1,1}) table.insert(list, "GB - "..cards.gb.."\n") end
 	-- if cards.rr > 0 then table.insert(list, {1,0,0}) table.insert(list, "*** RR - "..cards.rr.."\n") end
 	-- if cards.gg > 0 then table.insert(list, {0,1,0}) table.insert(list, "*** GG - "..cards.gg.."\n") end
 	-- if cards.bb > 0 then table.insert(list, {0,0,1}) table.insert(list, "*** BB - "..cards.bb.."\n") end
 	-- if cards.xx > 0 then table.insert(list, {1,1,1}) table.insert(list, "XX - "..cards.xx.."\n") end
		
	return list
end

function generateParent(race)
	local p = {}
	for y = 1, 9 do
		p[y] = {}
		for x = 1, 6 do
			if race == "q" then
				p[y][x] = {blocks[math.ceil(y/3)][math.ceil(x/3)]}
				p[y][x][2] = p[y][x][1]
			else
				p[y][x] = {generateGene(race), generateGene(race)}
			end
		end
	end
	
	p.counts = countGenes(p)
	p.cards = countCards(p)
		
	return p
end

function generateChild(p1, p2)
	local c = {}
	for y = 1, 9 do
		c[y] = {}
		for x = 1, 6 do
			c[y][x] = {p1[y][x][math.random(2)], p2[y][x][math.random(2)]}
		end
	end
	
	c.counts = countGenes(c)
	c.cards = countCards(c)
	
	return c
end

function generateGene(race)
	g = 0
	
	if not race or race == "p" then
		if math.random(2) == 1 then
			g = 0
		else
			g = math.random(4) - 1
		end
	elseif race == "r" then
		if math.random(2) == 1 then
			g = 0
		else
			if math.random(2) == 1 then
				g = 1
			else
				g = math.random(4) - 1
			end
		end
	elseif race == "g" then
		if math.random(2) == 1 then
			g = 0
		else
			if math.random(2) == 1 then
				g = 2
			else
				g = math.random(4) - 1
			end
		end
	elseif race == "b" then
		if math.random(2) == 1 then
			g = 0
		else
			if math.random(2) == 1 then
				g = 3
			else
				g = math.random(4) - 1
			end
		end
	elseif race == "t" then
		if math.random(2) == 1 then
			g = 0
		else
			if math.random(2) == 1 then
				g = 2
			else
				g = 3
			end
		end
	elseif race == "a" then
		g = math.random(3)
	elseif race == "w" then
		g = wIncrementor % 3 + 1
		wIncrementor = wIncrementor + 1
	end

	return g
end

--inefficient to count later... oh, well! >_<
function countGenes(u)
	local counts = {r = 0, g = 0, b = 0, a = 0}

	for y = 1, 9 do
		for x = 1, 6 do
			if u[y][x][1] == 1 then counts.r = counts.r + 1
			elseif u[y][x][1] == 2 then counts.g = counts.g + 1
			elseif u[y][x][1] == 3 then counts.b = counts.b + 1
			-- elseif u[y][x][1] == 4 or u[y][x][1] == 0 then counts.x = counts.x + 1
			end

			if u[y][x][2] == 1 then counts.r = counts.r + 1
			elseif u[y][x][2] == 2 then counts.g = counts.g + 1
			elseif u[y][x][2] == 3 then counts.b = counts.b + 1
			-- elseif u[y][x][2] == 4 or u[y][x][2] == 0 then counts.x = counts.x + 1
			end
		end
	end
	
	counts.a = counts.r + counts.g + counts.b
	
	return counts
end

function countCards(u)
	local cards = {rx = 0, gx = 0, bx = 0, rg = 0, rb = 0, gb = 0, rr = 0, gg = 0, bb = 0, xx = 0}

	for y = 1, 9 do
		for x = 1, 6 do
			local m = u[y][x][1]
			local n = u[y][x][2]
			if m == 1 and n == 0 or m == 0 and n == 1 then cards.rx = cards.rx + 1
			elseif m == 2 and n == 0 or m == 0 and n == 2 then cards.gx = cards.gx + 1
			elseif m == 3 and n == 0 or m == 0 and n == 3 then cards.bx = cards.bx + 1
			elseif m == 1 and n == 2 or m == 2 and n == 1 then cards.rg = cards.rg + 1
			elseif m == 1 and n == 3 or m == 3 and n == 1 then cards.rb = cards.rb + 1
			elseif m == 2 and n == 3 or m == 3 and n == 2 then cards.gb = cards.gb + 1
			elseif m == 1 and n == 1 then cards.rr = cards.rr + 1
			elseif m == 2 and n == 2 then cards.gg = cards.gg + 1
			elseif m == 3 and n == 3 then cards.bb = cards.bb + 1
			elseif m == 0 and n == 0 then cards.xx = cards.xx + 1
			end
		end
	end
	
	return cards	
end

function findCompatibility(p1, p2)
	local c = 0
	
	for y = 1, 9 do
		for x = 1, 6 do
			if p1[y][x][1] > 0 and p1[y][x][1] == p2[y][x][1] then c = c + 1 end
			if p1[y][x][1] > 0 and p1[y][x][1] > 0 and p1[y][x][1] == p2[y][x][2] then c = c + 1 end
			if p1[y][x][2] > 0 and p1[y][x][2] == p2[y][x][1] then c = c + 1 end
			if p1[y][x][2] > 0 and p1[y][x][2] == p2[y][x][2] then c = c + 1 end
		end
	end
	
	return c
end


function drawUnit(u, yOffset, xOffset)
	for y = 1, 9 do
		for x = 1, 6 do
			local m = u[y][x][1]
			local n = u[y][x][2]
			
			setGeneColor(m)
			love.graphics.rectangle("fill", xOffset + x * 30, yOffset + y * 20, 7, 15)
			setGeneColor(n)
			love.graphics.rectangle("fill", xOffset + 8 + x * 30, yOffset + y * 20, 7, 15)
			
			setCompositeGeneColor(m, n)
			love.graphics.rectangle("fill", xOffset + x * 30, yOffset + y * 20, 15, 10)
			love.graphics.setColor(0,0,0)
			love.graphics.rectangle("line", xOffset + x * 30, yOffset + y * 20, 15, 10)
		
			--glowing box
			if m == n and m ~= 0 then
				love.graphics.setColor(1, 1, 1, glow)
				love.graphics.rectangle("fill", xOffset + x * 30, yOffset + y * 20, 15, 15)
			end
		end
	end
	
	-- setGeneColor(1)
	love.graphics.setColor(1, 1, 1)
	
	--print cards
	-- if not moving then
	-- 	love.graphics.print({{1,0,0}, u.counts.r, {1,1,1}, ", ", {0,1,0}, u.counts.g, {1,1,1}, ", ", {0,0,1}, u.counts.b, {1,1,1}, ", "..u.counts.a}, xOffset + 20, yOffset + 200)
	--
	-- 	love.graphics.print(generateCardList(u.cards), xOffset + 50, yOffset + 225)
	-- end
	
	-- lines
	-- love.graphics.line(xOffset + 77.5, yOffset + 20, xOffset + 77.5, yOffset + 195)
	-- love.graphics.line(xOffset + 137.5, yOffset + 20, xOffset + 137.5, yOffset + 195)
	-- love.graphics.line(xOffset + 20, yOffset + 77.5, xOffset + 195, yOffset + 77.5)
	-- love.graphics.line(xOffset + 20, yOffset + 137.5, xOffset + 195, yOffset + 137.5)
	
	--alternate lines
	for i = 1, 5 do
		love.graphics.line(xOffset + 22.5 + i * 30, yOffset + 20, xOffset + 22.5 + i * 30, yOffset + 195)
	end
end

function generateBlocks()
	blocks = {
		{math.random(4) - 1, math.random(4) - 1, math.random(4) - 1}, 
		{math.random(4) - 1, math.random(4) - 1, math.random(4) - 1}, 
		{math.random(4) - 1, math.random(4) - 1, math.random(4) - 1}
	}
end

function setGeneColor(g)
	if g == 1 then
		love.graphics.setColor(1,0,0)
	elseif g == 2 then
		love.graphics.setColor(0,0.9,0)
	elseif g == 3 then
		love.graphics.setColor(0,0,1)
	elseif g == 4 or g == 0 then
		love.graphics.setColor(0.1,0.1,0.1)
	end
end

function setCompositeGeneColor(g1, g2)
	local r, g, b = 0.1, 0.1, 0.1
	if g1 == 1 or g2 == 1 then r = 1 end
	if g1 == 2 or g2 == 2 then g = 1 end
	if g1 == 3 or g2 == 3 then b = 1 end
	
	love.graphics.setColor(r, g, b)
end