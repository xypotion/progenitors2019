--this might ultimately be the wrong approach, but i'm gonna try it.

activities = {
	{
		key = 'a', name = "Alchemy", 
		description = "Attempt to make potions",
		validRooms = {"Lab"},
		outside = false,
		-- requiredFood = 1
	},
	{
		key = 'b', name = "Build", 
		description = "Build new structures, or improve or convert structures inside rooms",
		validRooms = {"Empty"},
		outside = false,
		always = true,
		--TODO this also needs to be drawn & assigned separately. separate constructions separate rooms, have "progress", can't be mixed, etc.
		--i think each room will have a "construction" attribute with "new room" and "progress". building can just continue that OR cancel it
		--when you select this activity, the next choice is (1) build a new room, (2) improve a room, or (3) help other (show that first?)
			--that list can be long, so prepare to paginate :/
			--this menu is actually going to be pretty complicated! maybe come back to it later
	},
	{
		key = 'c', name = "Cook", 
		description = "Cook food to make it last longer",
		validRooms = {"Kitchen"},
		outside = false,
	}, --food
	{
		key = 'd', name = "Dig", 
		description = "Dig into the mountain to make more rooms",
		outside = false,
		always = true,
		-- validRooms = {}, --if not validRooms then just do it? or handle specially somehow
	},
	{
		key = 'e', name = "Eat", 
		description = "Consume a lot to get stronger; eat 2 extra food",
		validRooms = {"Residence"},
		outside = false,
	}, --? i.e. bulk up (eat a lot more food, for growth)
	-- {key = 'e', name = "Enlarge",
	-- 	validRooms = {"Lab"},
	-- }, --rooms
	{
		key = 'f', name = "Fast", 
		description = "Eat nothing, and pray to the moon",
		validRooms = {"Residence"},
		outside = false,
	},
	{
		key = 'g', name = "Gather", 
		description = "Collect items from outside",
		-- validRooms = {"Lab"},
		outside = true,
	},
	{
		key = 'h', name = "Heal", 
		description = "Help heal the wounded",
		-- validRooms = {"Lab"},
		outside = false,
	},
	{
		key = 'i', name = "Investigate", 
		description = "Learn about distant areas",
		-- validRooms = {"Lab"},
		outside = true,
	},
	{
		key = 'm', name = "Mate", 
		description = "Pray for children with another resident. Takes time.",
		validRooms = {"Residence", "A shrine"},
		outside = false,
		--submenu here should be fairly easy, at least at a basic level (i.e. not showing family members, previous mates, etc)
		--ah, and don't forget about sample children. that'll have to be another layer later, after skills are implemented
	},
	{
		key = 'p', name = "Pray", 
		description = "",
		validRooms = {"A shrine"},
		outside = false,
	}, --food
	{
		key = 's', name = "Scout",
		description = "Learn about nearby enemies",
		outside = true, --kinda. CAN scout world areas, or just next approaching army
	},
	{
		key = 't', name = "Train", 
		description = "Strengthen your body; Max Lv +2 and eat 1 more food",
		validRooms = {"Dojo"},
		outside = false, --also just kinda. CAN train in outside areas... maybe.
	},
	{
		key = 'w', name = "Welcome", 
		description = "Greet visitors at the gate",
		validRooms = {"Entry"},
		outside = false,
	}, --? at the gate. "Greet" would be better...
	-- {
	-- 	key = 'x', name = "Empty",
	-- 	description = "Clear a room out and reclaim materials",
	-- 	outside = false,
	-- 	always = true,
	-- }, --turn any room into an Empty room. 
	--should this maybe be an instant thing that the player can do? doesn't take time? OR just let rooms be converted into other rooms
	{
		key = 'z', name = "Idle", 
		description = "Do nothing. Some residents will get bored.",
		outside = false,
		always = true,
		-- validRooms = {"Residence"}, --doesn't matter where
	},
	-- x = "Recuperate" --happens automatically when wounded BUT TODO player must choose what room to put unit in
}