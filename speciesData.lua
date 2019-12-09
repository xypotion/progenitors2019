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
	Mantis = {
		stats = {maxHP = 1, int = 4, str = 4, agl = 1}, rs = 2
	},
	Crab = {
		stats = {maxHP = 3, int = 2, str = 3, agl = 2},
	},
}

--decoupling these from races because they will probably be moved around a lot
--various gameplay logics will just look at these RS IDs to account for racial skills
RS = {} -- Racial Skills
RS[1] = {name = "Long-lived", desc = "Old age sets in later than normal."} --at max level, units eventually become "old" and die
RS[2] = {name = "Pious", desc = "Generates more LP at the full moon."}
RS[3] = {name = "Practitioner", desc = "Heals the wounded more thoroughly."} --"scarred" status is less harsh?
RS[4] = {name = "Scavenger", desc = "Can eat rot."}
RS[5] = {name = "Team Player", desc = "Gets more done in large groups."}
RS[6] = {name = "Honey", desc = "Crafts health elixirs with ease."}
RS[7] = {name = "Far-seeing", desc = "Very effective at scouting enemies."}
RS[8] = {name = "Prolific", desc = "Takes less time to produce and raise offspring."}
RS[9] = {name = "Hoarder", desc = "Good at preserving food."}
RS[10] = {name = "Cute", desc = "Charms visitors at the gate."}
RS[11] = {name = "Tough", desc = "Cannot be wounded."}
RS[12] = {name = "Adaptive", desc = "Will permanently copy random alleles when working with others."}
RS[13] = {name = "Sea Spy", desc = "Can investigate and evade danger easily in underwater areas."}
RS[14] = {name = "Water Warrior", desc = "Can gather and evade danger easily in underwater areas."}
RS[15] = {name = "", desc = ""}
RS[16] = {name = "", desc = ""}
