speciesBaseStatMultiplier = 1
randomSpeciesThreshold = 7/8 --total - 1 over total
-- 3-(1/3) = (3-1)/3. weird.

function randomSpecies()
	local keyset = {}
	for k in pairs(speciesData) do
	    table.insert(keyset, k)
	end
	
	return keyset[math.random(#keyset)]
end

speciesData = {
	Snake = {
		stats = {maxHP = 2, int = 2, str = 3, agl = 3},
	},
	Vulture = {
		stats = {maxHP = 3, int = 2, str = 2, agl = 3},
	},
	Ant = {
		stats = {maxHP = 2, int = 3, str = 3, agl = 2},
	},
	Bee = {
		stats = {maxHP = 1, int = 3, str = 3, agl = 3},
	},
	Elephant = {
		stats = {maxHP = 4, int = 2, str = 3, agl = 1},
	},
	Falcon = {
		stats = {maxHP = 2, int = 3, str = 2, agl = 3},
	},
	Rabbit = {
		stats = {maxHP = 3, int = 2, str = 1, agl = 4},
	},
	Squirrel = {
		stats = {maxHP = 2, int = 2, str = 2, agl = 4},
	},
	Koala = {
		stats = {maxHP = 4, int = 2, str = 2, agl = 2},
	},
	Bear = {
		stats = {maxHP = 3, int = 2, str = 4, agl = 1},
	},
	Chameleon = {
		stats = {maxHP = 1, int = 4, str = 2, agl = 3},
	},
	Octopus = {
		stats = {maxHP = 2, int = 4, str = 2, agl = 2},
	},
}