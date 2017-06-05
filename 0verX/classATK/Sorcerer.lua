--[[

	--------------------------------------------------
	Copyright (C) 2014 VaanC

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
--[[
KNOWN STATE ID'S
- State Name = Stunning Shot II - State ID = 679
- State Name = Stunned - State ID = 8217
- State Name = Entangling Shot III - State ID = 676
- State Name = No Name (Godstone: Deltras's Loyalty) State ID = 8540
- State Name = Shackle Arrow I - State ID = 672
- State Name = Sleep Arrow I - State ID = 695
]]--

function CountMobs( arg_target, Distance )

	local i = 0;

	-- Iterate through all entities
	for ID, Entity in DictionaryIterator( EntityList:GetList()) do
		-- Check if the entiy is valid.
		if Entity ~= nil then
			-- Retrieve the entity state.
			local EntityState = Entity:GetState();
			-- Check if the entity state is valid.
			if EntityState ~= nil then
				-- Check if this is a living monster that is in range.
				if Entity:IsMonster() and not Entity:IsDead() and Entity:IsHostile() and EntityTarget:GetPosition():DistanceToPosition( Entity:GetPosition()) <= Distance then
					-- Check if this entity is sleeping
					if EntityState:GetState( Helper:CheckName( "Sleep Arrow" )) ~= nil then
						return 0;
					-- Increment the number.
					else
						i = i + 1;
					end
				end
			end
		end
	end

	return i;

end

function SleepMultipleAttacker( EntityTarget, AttackRange )
	-- Check if we have stored a target.
	if self._SleepTarget ~= nil then
		-- Check if the current target is the stored target.
		if self._SleepTarget:GetID() == Player:GetTargetID() then
			-- Check if Sleep Arrow is available.
			if Helper:CheckAvailable( "Sleep Arrow" ) then
				-- Shoot the Sleep Arrow.
				Helper:CheckExecute( "Sleep Arrow" );
				-- Indicate we cannot continue attacking.
				return false;
			else
				-- Set the target.
				Player:SetTarget( self._SleepTargetRestore );
				-- Indicate we cannot continue attacking.
				return false;
			end
		-- Check if the current target is the original target.
		elseif not Helper:CheckAvailable( "Sleep Arrow" ) and self._SleepTargetRestore:GetID() == EntityTarget:GetID() then
			-- Clear the sleep target.
			self._SleepTarget = nil;
			-- Indicate we cannot continue attacking.
			return true;
		else
			-- Set the target.
			Player:SetTarget( self._SleepTarget );
			-- Indicate we cannot continue attacking.
			return false;
		end
	end
	-- Check if Sleep Arrow is available.
	if Helper:CheckAvailable( "Sleep Arrow" ) then
		-- Loop through the entities.
		for ID, Entity in DictionaryIterator( EntityList:GetList()) do
			-- Check if this entity is a monster, is not friendly and decided to attack me (and obviously is not my current target).
			if not Entity:IsDead() and Entity:IsMonster() and not Entity:IsFriendly() and Entity:GetTargetID() == Player:GetID() and Entity:GetID() ~= EntityTarget:GetID() then
				-- Check if the entity that is attacking us is within range.
				if Entity:GetPosition():DistanceToPosition( Player:GetPosition()) <= AttackRange then
					-- Store the sleep target.
					self._SleepTarget = Entity;
					-- Store the restore target.
					self._SleepTargetRestore = EntityTarget;
					-- Set the target.
					Player:SetTarget( Entity );
					-- Indicate we cannot continue attacking.
					return false;
				end
			end
		end
	end
	-- Indicate we can continue attacking.
	return true;
end

-- This is the class chain information list.  It is NOT a priority list, this is merely to help the class know when it has
-- started a chain so it knows to only use skills from that chain until the target dies OR until the chain times out.
local m_chain_info =
	{
		["Stunning Shot"] = { "Stunning Shot", "Rupture Arrow" },
		["Swift Shot"] = { "Swift Shot", "Arrow Strike", "Spiral Arrow" },
		["Spread Shot"] = { "Spread Shot" },
		--["Arrow Assault"] = { "Arrow Assault" },
		["Remove Shock"] = { "Remove Shock", "Seizure Arrow" }
	};

-- Buffs you want to apply before starting an attack or while traveling.
local m_pre_attack_buffs =
	{
		{ skill_name = "Nature's Favor", conditions = { { condition_type = "Buff_Not_Active" } } },
		{ skill_name = "Sharpen Arrows", conditions = { { condition_type = "Buff_Not_Active" } } },
		{ skill_name = "Breath of Nature", conditions = { { condition_type = "Buff_Not_Active" } } },
		{ skill_name = "Keen Cleverness", conditions = { { condition_type = "Buff_Not_Active" } } },
		{ skill_name = "Mau Form", conditions = { { condition_type = "Buff_Not_Active" }, { condition_type = "Player_DP", compare = ">=", compare_value = "2000" } } }
	};

-- Buffs or self-skills you want to use in the middle of battle
local m_attack_buffs =
	{
		{ skill_name = "Bestial Fury", conditions = { { condition_type = "Buff_Not_Active" }, { condition_type = "arg_range", compare = "<=", compare_value = "15" } } },
		--{ skill_name = "Aiming", conditions = { { condition_type = "Buff_Not_Active" } } },
		--{ skill_name = "Strong Shots", conditions = { { condition_type = "Buff_Not_Active" } } },
		{ skill_name = "Focused Shots", conditions = { { condition_type = "Buff_Not_Active" } } },
		{ skill_name = "Speed of the Wind", conditions = { { condition_type = "Buff_Not_Active" } } },
		{ skill_name = "Bow of Blessing", conditions = { { condition_type = "Buff_Not_Active" } } },
		{ skill_name = "Devotion", conditions = { { condition_type = "Buff_Not_Active" } } }
	};

-- Skills you want to use to START an attack. I do not recommend chain skills here since there is too long of a delay in AS between attacks at this point for some reason and they tend to time-out
local m_pull_skills =
	{
		{ skill_name = "Entangling Shot" },
		{ skill_name = "Swift Shot" },
		{ skill_name = "Shock Arrow" },
		{ skill_name = "Venomfinder Shot" },
		{ skill_name = "Unerring Arrow" },
		{ skill_name = "Explosive Arrow" },
		{ skill_name = "Holy Arrow" },
		{ skill_name = "Brightwing Arrow" },
		{ skill_name = "Attack/Chat" }
	};

-- Conditional skills are priority skills which rely on special conditions that usually need to be responded to no matter what (like Remove Shock...if its available you probably need it NOW :) )
local m_conditional_skills =
	{
		{ skill_name = "Silence Arrow", conditions = { { condition_type = "Target_Casting" } }, break_chain = false },
		{ skill_name = "Focused Evasion", conditions = { { condition_type = "Target_Attacking" }, { condition_type = "arg_range", compare = "<=", compare_value = "6" } }, break_chain = false },
		{ skill_name = "Remove Shock", break_chain = true }
	};

-- You MUST list the skills from LAST in chain to first for them to fire properly (Aion reports earlier skills as off CD even if you've moved to next step in chain)
local m_chain_skills =
	{
		{ skill_name = "Seizure Arrow", conditions = { { condition_type = "Player_Health_Percent", compare = "<", compare_value = "50" } } },
		{ skill_name = "Rupture Arrow" },
		{ skill_name = "Spiral Arrow" },
		{ skill_name = "Arrow Strike" },
		{ skill_name = "Spread Shot" },
		{ skill_name = "Stunning Shot" },
		--{ skill_name = "Arrow Assault" },
		{ skill_name = "Finishong Arrow" },
		{ skill_name = "Stillness Arrow" },
		{ skill_name = "Misery Shot" },
		{ skill_name = "Aerial Wild Shot" }
	};

-- Skills to use during normal attack (not pull, not chain, just attacking)
local l_attack_skills =
	{
		{ skill_name = "Entangling Shot" },
		{ skill_name = "Swift Shot" },
		{ skill_name = "Shock Arrow" },
		{ skill_name = "Venomfinder Shot" },
		{ skill_name = "Stunning Shot" },
		{ skill_name = "Unerring Arrow" },
		{ skill_name = "Explosive Arrow" },
		{ skill_name = "Holy Arrow" },
		{ skill_name = "Brightwing Arrow" },
		{ skill_name = "Deadshot" },
		{ skill_name = "Spread Shot" },
		--{ skill_name = "Arrow Assault" },
		{ skill_name = "Attack/Chat" }
	};

-- Flag telling us when we are mid-chain
local m_doing_chain_skills = false;
-- Time to add to "now" to wait for another chain skill to successfully fire before giving up
local m_chain_timeout_interval = 1500;
-- Literal time in milliseconds of time when we should give up on current chain of skills
local m_chain_timeout_time = 0;
-- Index into the list of skills for last chain skill used
local m_chain_index = -1;
-- Holds the list of chain skills
local m_current_chain = nil;
-- Skill name of start of current chain
local m_chain_start_skill = nil;

-- Current target for attack, used to know if we are mid-fight or starting a pull
local m_target = nil;
-- Reset all the chain related variables, used when we either killed a target or a chain timed out.
function _reset_chain_variables()
	-- Flag telling us when we are mid-chain
	m_doing_chain_skills = false;
	-- Timeout to give up on a chain to avoid getting stuck
	m_chain_timeout_time = 0;
	-- Index into the list of skills for last chain skill used
	m_chain_index = -1;
	-- Holds the list of chain skills
	m_current_chain = nil;
	-- Skill name of start of current chain
	m_chain_start_skill = nil;

	return true;
end

-- Check to see if all the conditions specified for a skill have been met
function _check_conditions( arg_skill_info, arg_target, arg_range, arg_stunned )

	-- Default result if there are no conditions is true...so all skills can be run through here and quickly result in true
	local l_result = false;
	local l_player_pos = Player:GetPosition();
	local l_range = l_player_pos:DistanceToPosition( arg_target:GetPosition() );
	local l_target_state = arg_target:GetState();
	local l_attack_range = Player:GetAttackRange();
	local l_player_state = Player:GetState();
	local l_skill_name = arg_skill_info.skill_name;
	local l_conditions = arg_skill_info.conditions;
	local l_value_compare_types =
		{
			["arg_range"] = true,
			["Player_Health_Percent"] = true,
			["Player_Mana_Percent"] = true,
			["Target_Health_Percent"] = true,
			["Player_DP"] = true
		};
	-- If there are NO conditions to check then return true
	if l_conditions == nil then
		return true;
	end

	-- For each set of condition parameters
	for key, l_condition in ipairs(l_conditions) do
		local l_first_value = nil;
		local l_second_value = nil;
		local l_compare = nil;
		local l_condition_type = l_condition.condition_type;
		-- If the condition type was NOT set to something then write a warning message and return false (no condition is okay, but a condition with a nil type is not good)
		if (l_condition_type == nil) then
			--Write("Condition type was nil for skill '" .. l_skill_name .. "' so returning false, but this is a bug in your skills list.");
			return false;
		else -- If we got a condition type, then set up the comparison values (first and second) or do any special case tests
			if 			l_condition_type == "arg_range" then
				l_first_value = tonumber(l_range);
				l_second_value = tonumber(l_condition.compare_value);

			elseif		l_condition_type == "Player_Health_Percent" then
				l_first_value = tonumber(Player:GetHealth());
				l_second_value = tonumber(l_condition.compare_value);

			elseif		l_condition_type == "Player_Mana_Percent" then
				l_first_value = tonumber(Player:GetMana());
				l_second_value = tonumber(l_condition.compare_value);

			elseif		l_condition_type == "Target_Health_Percent" then
				l_first_value = tonumber(arg_target:GetHealth());
				l_second_value = tonumber(l_condition.compare_value);

			elseif		l_condition_type == "Player_DP" then
				l_first_value = tonumber(Player:GetDP());
				l_second_value = tonumber(l_condition.compare_value);

			elseif		l_condition_type == "Target_Casting" then
				if (arg_target:GetSkillID() ~= 0) and (SkillList[arg_target:GetSkillID()]:IsMagical()) and (arg_target:GetSkillTime() >= 500) then
					l_result = true;
				end

			elseif		l_condition_type == "Target_Attacking" then
				if (arg_target:GetSkillID() ~= 0) and (SkillList[arg_target:GetSkillID()]:IsAttack()) and (arg_target:GetSkillTime() >= 500) then
					l_result = true;
				end

			elseif		l_condition_type == "Skill_On_Cooldown" then
				if (l_condition.compare_value == nil) then
					--Write("Comparison value (should be skill name) was nil for skill '" .. l_skill_name .. "' for skill on cooldown condition so returning false, but this is a bug in your skills list.");
					return false;
				else
					-- The test condition is TRUE if the skill is NOT available, meaning it is on cool down.
					l_result = not Helper:CheckAvailable(l_condition.compare_value);
				end

			elseif 		l_condition_type == "Buff_Not_Active" then
				local l_target_state = arg_target:GetState();
				l_result = (l_target_state:GetState( Helper:CheckName( l_skill_name )) == nil);
			end

			-- More efficient way to check if the condition type is one which requires numerically comparing values
			if l_value_compare_types[l_condition_type] ~= nil then
				l_compare = l_condition.compare;
				-- Check to make sure we were given a comparison operator
				if (l_compare == nil) then
					--Write("Condition comparison operator was nil for skill '" .. l_skill_name .. "' so returning false, but this is a bug in your skills list.");
					return false;
				end
				-- Check to make sure we were given a comparison value to compare the in game variable to
				if l_second_value == nil then
					Write(l_condition_type .. " condition for skill '" .. l_skill_name .. "' has nil comparison value so returning false, but this is a bug in your skills list.");
					return false;
				end
				-- Now check which type of comparison operator to use and perform that comparison (first OPERATOR second)
				if 		l_compare == ">" then
					l_result = (l_first_value > l_second_value);
				elseif	l_compare == ">=" then
					l_result = (l_first_value >= l_second_value);
				elseif	l_compare == "<" then
					l_result = (l_first_value < l_second_value);
				elseif	l_compare == "<=" then
					l_result = (l_first_value <= l_second_value);
				elseif	l_compare == "==" then
					l_result = (l_first_value == l_second_value);
				end
			end
		end
		-- End the loop as soon as we fail any condition
		if not l_result then
			break;
		end
	end

	return l_result;
end

-- Search through the list of skills until one is found which is both available and meets any conditions specified for it, then execute it.
function _do_skills(arg_skills, arg_target, arg_range, arg_stunned)

	-- Loop through the given skill list checking if the skill is available and any conditions included test as true
	for key, l_skill_info in ipairs(arg_skills) do
		local l_skill_name = l_skill_info.skill_name;
		if (l_skill_name ~= nil) then
			local l_conditions_passed = self:_check_conditions( l_skill_info, arg_target, arg_range, arg_stunned );
			if (l_conditions_passed) then
				local l_available = Helper:CheckAvailable( l_skill_name );
				if l_available then
					-- Check if this is the start of a chain
					if m_chain_info[l_skill_name] ~= nil then
						m_doing_chain_skills = true;
						m_chain_index = 1;
						m_current_chain = m_chain_info[l_skill_name];
						m_chain_start_skill = l_skill_name;
						Helper:CheckExecute( l_skill_name, arg_target );
						m_chain_timeout_time = Time() + m_chain_timeout_interval;
						return false;
					elseif m_doing_chain_skills then
						local l_found_skill_in_chain = false;
						for chain_index, chain_skill in ipairs(m_current_chain) do
							if l_skill_name == chain_skill then
								l_found_skill_in_chain = true;
								if chain_index >= m_chain_index then
									m_chain_index = chain_index;
									Helper:CheckExecute( l_skill_name, arg_target );
									m_chain_timeout_time = Time() + m_chain_timeout_interval;
									return false;
								end
							end
						end
						-- If this skill isn't part of the chain AND the skill has the break_chain flag set to true, then we execute it.
						if (not l_found_skill_in_chain) and (l_skill_info.break_chain == true) then
							Helper:CheckExecute( l_skill_name, arg_target );
							return false;
						end
					else
						Helper:CheckExecute( l_skill_name, arg_target );
						return false;
					end
				end
			end
		end
	end
	-- Indicate nothing done so other actions can potentially be taken this tick.
	return true;
end


--- Perform the attack routine on the selected target.
--
-- @param       Entity  Contains the entity we have targeted.
-- @param       double  Contains the distance to the target
-- @param       bool    Indicates whether or not the target is stunned.
-- @return      bool
function Attack( arg_target, arg_range, arg_stunned )


	-- Check if we are allowed to sleep attackers.
	if Settings.Ranger.AllowSleep and not self:SleepMultipleAttacker( arg_target, arg_range ) then
		return false;
	end

	--Food Checks / Scrolls;
	if Settings.CritFood then
		self:CheckCritFood();
	end

	if Settings.AttackFood then
		self:CheckAttackFood();
	end

	if Settings.NaturalHeal then
		self:CheckNaturalHeal();
	end

	if Settings.AttackScroll then
		self:CheckAttackScroll();
	end

	if Settings.RunScroll then
		self:CheckRunScroll();
	end

	if arg_target:IsDead() then
		self.m_target = nil
	end


	-- If we haven't started attacking this entity yet...do pre-attack buffs, then attack buffs, then the actual pull
	if (self.m_target ~= arg_target:GetID()) and (not arg_target:IsDead()) then
		--Write ("Starting new pull.");

		-- If starting a new pull then not doing a chain (even though sometimes Aion will let you finish a chain on a different mob...we will ignore that glitch)
		self:_reset_chain_variables();

		-- If we are doing a pre-attack buff, then return false to indicate nothing more can be done until next tick
		if not self:_do_skills(m_pre_attack_buffs, Player) then
			return false;
		end
		-- If we are doing a mid-attack buff (pre-attack only happens once, but during attack can happen pre-pull or mid attack), then return false to indicate nothing more can be done this tick.
		if not self:_do_skills(m_attack_buffs, Player) then
			return false;
		end
		-- If we actually manage to execute a pull attack, then return false to indicate nothing more can be done this tick.
		if not self:_do_skills( m_pull_skills, arg_target, arg_range, arg_stunned ) then
			self.m_target = arg_target:GetID();
			return false;
		end
	-- Else we HAVE started attacking this entity already so do full attack routine
	elseif (not arg_target:IsDead()) then
		--Write ("Continuing after pull.");

		-- If we're doing a chain and the chain has timed out (too long between chain skills) then reset to not doing a chain and move on.
		if ( m_doing_chain_skills ) and ( Time() > m_chain_timeout_time ) then
			--Write("Chain '" .. m_chain_start_skill .. "' timed out so resetting variables.");
			self:_reset_chain_variables();
		end

		if ( m_doing_chain_skills ) then
			-- Conditionals override everything...should be critical skills...
			--Write("In middle of chain skill, checking conditional skills.");
			if not self:_do_skills( m_conditional_skills, arg_target, arg_range, arg_stunned ) then
				return false;
			else
				--Write("In middle of chain skill, checking chain skills.");
			-- Check to see if we do any chain skills, and return false to indicate nothing more can be done until next tick.
				if not self:_do_skills( m_chain_skills, arg_target, arg_range, arg_stunned ) then
					return false;
				end
			end
		else
			-- Check to see if we do any conditional skills (entity stunned, player stunned, etc etc skills), and return false to indicate nothing more can be done until next tick.
			if not self:_do_skills( m_conditional_skills, arg_target, arg_range, arg_stunned ) then
				return false;
			-- Check to see if we do any chain skills, and return false to indicate nothing more can be done until next tick.
			elseif not self:_do_skills( m_chain_skills, arg_target, arg_range, arg_stunned ) then
				return false;
			-- Check if need to do any mid-attack buffs, and return false to indicate nothing more can be done until next tick if we perform a buff
			elseif not self:_do_skills(m_attack_buffs, Player) then
				return false;
			-- Check to see if we do any normal attack skills, and return false to indicate nothing more can be done until next tick.
			elseif not self:_do_skills( l_attack_skills, arg_target, arg_range, arg_stunned ) then
				return false;
			end
		end

	end
	-- Indicate nothing done so other actions can potentially be taken this tick.
	return true;
end


--- Perform the required pause checks.
--
-- @return	bool
function Pause()

	if not self:_do_skills( m_pre_attack_buffs, Player ) then
		return false;
	end

	-- Nothing was executed, continue with other functions.
	return true;

end

-- Handle any tasks which should happen when the current target is killed
function TargetDied(arg_target)

	m_target = nil;

	-- Nothing was executed, continue with other functions.
	return true;
end