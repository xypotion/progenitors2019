--this might ultimately be the wrong approach, but i'm gonna try it.

activities = {
	{
		key = 'a', name = "Alchemy", 
		description = "Attempt to make potions",
		validRooms = {"Lab"},
		-- requiredFood = 1
	},
	{
		key = 'b', name = "Bulk", 
		description = "Consume a lot to get stronger; eat 2 extra food",
		validRooms = {"Residence"},
	}, --? i.e. bulk up (eat a lot more food, for growth)
	{
		key = 'c', name = "Construct", 
		description = "Build or improve structures inside rooms",
		validRooms = {"Empty"},
	}, --rooms
	{
		key = 'd', name = "Dig", 
		description = "Dig into the mountain to make more rooms",
		-- validRooms = {}, --if not validRooms then just do it? or handle specially somehow
	},
	-- {key = 'e', name = "Enlarge",
	-- 	validRooms = {"Lab"},
	-- }, --rooms
	{
		key = 'f', name = "Fast", 
		description = "Eat nothing, and pray to the moon",
		validRooms = {"Residence"},
	},
	{
		key = 'g', name = "Gather", 
		description = "Collect items from outside",
		-- validRooms = {"Lab"},
	},
	{
		key = 'h', name = "Heal", 
		description = "Help heal the wounded",
		-- validRooms = {"Lab"},
	}, --others! not self
	{
		key = 'i', name = "Investigate", 
		description = "something",
		-- validRooms = {"Lab"},
	},
	{
		key = 'm', name = "Mate", 
		description = "something",
		validRooms = {"Residence", "A shrine"},
	},
	{
		key = 'p', name = "Preserve", 
		description = "Cook food to make it last longer",
		validRooms = {"Kitchen"},
	}, --food
	{
		key = 's', name = "Scout",
		description = "Learn about nearby enemies",
		-- validRooms = {"Kitchen"},
	}, --? just to sort unassigned units, but maybe list elsewhere...
	{
		key = 't', name = "Train", 
		description = "Strengthen your body; Max Lv +2 and eat 1 more food",
		validRooms = {"Dojo"},
	},
	{
		key = 'w', name = "Welcome", 
		description = "Greet visitors",
		validRooms = {"Entry"},
	}, --? at the gate. "Greet" would be better...
	{
		key = 'x', name = "Empty", 
		description = "Clear a room out and reclaim materials",
		-- validRooms = {"Lab"},
	}, --turn any room into an Empty room
	{
		key = 'z', name = "Idle", 
		description = "Do nothing. Some residents will get bored....",
		-- validRooms = {"Residence"},
	},
	-- x = "Recuperate" --happens automatically when wounded BUT TODO player must choose what room to put unit in
}