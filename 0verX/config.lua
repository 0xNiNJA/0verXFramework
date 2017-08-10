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
			buff_scroll_numbers = { 9959 };
			food_scroll_names = {  "Greater Running Scroll","Greater Courage Scroll","Major Crit Strike Scroll","Yasba's Grace - Valid for 30 days"};
			inventory_item_cool_down = 1;
			timer = 0;
			SuperGlideDistanceAccurate = 3;
			-- change this to the event item
			inventory_item_name = "Greater Courage Scroll";
			-- change this to the cool down, in seconds
			inventory_item_cool_down = 4;



	-- "Protect me and you shall never fall."
		self.Cleric = {
			-- Indicates whether or not attacking is allowed. Cleric version to allow following and such.
			AllowAttack = true,
			-- Indicates whether or not delaying for a Noble Energy or Holy Servant is required before attacking.
			AllowAttackDelay = false,
			-- Indicates whether or not high mana consumption skills such as Enfeebling Burst and Call Lightning.
			AllowAttackMana = true,
		-- Indicates whether or not approaching a target is allowed. Auto approach must be enabled for this to work.
			AllowApproach = true,
			-- Indicates whether or not buffing force members is allowed. Disable this if you want to run as an assisting script.
			AllowBuff = true,
			-- Indicates whether or not buffing force members is allowed.
			AllowBuffForce = true,
			-- Indicates whether or not healing is allowed. Disable this if you want to run as an assisting script.
			AllowHealing = true,
			-- Indicates whether or not using Rebirth is allowed.
			AllowRebirth = true,
			-- Indicates whether or not using Summer Circle is allowed.
			AllowSummerCircleBuff = true,
			-- Indicates whether or not using Winter Circle is allowed.
			AllowWinterCircleBuff = false
		};
		
		-- "Nothing can stand in my way!"
		self.Gladiator = {
			-- Indicates whether or not to allow area-of-attack skills.
			AllowAoe = true,
			-- Indicates whether or not to allow Taloc's Hollow Skills
			AllowTalocHollow = true
		};
		
		-- "Chase me or run away. Either way, you'll only die tired."
		self.Ranger = {
			-- Indicates whether or not to allow area-of-attack skills.
			AllowAoe = true,
			-- Indicates whether Mau Form is allowed when grinding.
			AllowMauWhenGrinding = true,
			-- Indicates whether or not to allow trap skills.
			AllowTraps = true,
			-- Indicates whether or not sleeping multiple attackers is allowed.
			AllowSleep = true
		};
		
		-- "This will only hurt for a second."
		self.Sorcerer = {
			-- Indicates whether or not to allow boss mode, which uses a different rotation without slow effects.
			AllowGroupRotation = false,
			-- Indicates whether MP conservation is allowed (Lumiel's Wisdom).
			AllowMpConservation = true
		};
		
		-- Songweaver
		self.Songweaver = {
			-- Indicates whether or not attacking is allowed. Cleric version to allow following and such.
			AllowAttack = true,
			-- Indicates whether or not approaching a target is allowed. Auto approach must be enabled for this to work.
			AllowApproach = true,
			-- Indicates whether or not buffing force members is allowed. Disable this if you want to run as an assisting script.
			AllowBuff = true,
			-- Indicates whether or not sleeping multiple attackers is allowed.
			AllowSleep = false,
			-- Indicates whether or not healing is allowed. Disable this if you want to run as an assisting script.
			AllowHealing = true,
			-- Indicates whether or not healing is allowed. Disable this if you want to run as an assisting script.
			AllowHealingMana = false
		};
		
		-- "Never fight alone."
		self.SpiritMaster = {
			-- Indicates whether or not to preserve mana. Damage-over-time skills are not applied after 50%.
			AllowPreserveMana = true,
			-- Indicates whehter initial threat with a spirit is prefered.
			AllowInitialThreat = true
		};
		
		-- "You're only as good as your armor."
		self.Templar = {
			-- Indicates whether or not Doom Lure is allowed, which is pointless on bosses.
			AllowDoomLure = true,
			-- Indicates whether or not skills using DP are allowed.
			AllowDpSkills = true,
			-- Indicates whether or not taunting is allowed and should be performed.
			AllowTaunting = false,
			-- Indicates whether or not to taunt without continously spamming it.
			AllowSmartTaunting = true
		};

		-- Check if the player-specific settings file exists and load values from it.
		if Settings ~= nil then

			-- Load the settings from the file to allow the configuration of the framework.
			Settings:Initialize();
			
			-- Loop through the keys and values exposed by the Settings object and import them.
			for k, v in pairs( Settings ) do
				self[k] = v;
			end
			
		end
				
	end