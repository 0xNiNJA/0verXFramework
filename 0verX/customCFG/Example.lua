--[[

	--------------------------------------------------
	Copyright (C) 2011 Blastradius

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
	--------------------------------------------------
	
]]--

--- Initializes the settings in the framework. You can change settings here or in your loaded script.
--
-- @return	void

function Initialize()

			-- Attempt to load a player-specific settings file, which will take priority over the configured values here.
		local Settings = Include( "0verX/Settings/" .. Player:GetName() .. ".lua" );	
			food_scroll_numbers = { 9960,9959,9957,10350 };
			food_scroll_names = {  "Greater Running Scroll","Greater Courage Scroll","Major Crit Strike Scroll","Yasba's Grace - Valid for 30 days"};
			inventory_item_cool_down = 1;
			timer = 0;

			-- change this to the event item
			inventory_item_name = "Greater Courage Scroll";
			-- change this to the cool down, in seconds
			inventory_item_cool_down = 4;

		
end