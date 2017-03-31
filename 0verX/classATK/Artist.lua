
--[[

	--------------------------------------------------
	Copyright (C) 2013 Blastradius + VaanC

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


--- (Private Function) Checks the healing requirements for the provided entity.
--
-- @param	Entity	Contains the entity to perform healing on.
-- @param	double	Contains the
-- @return	bool

function _CheckHeal( Entity )

	-- Retrieve the range of the entity compared to my own character position.
	local Range = Player:GetPosition():DistanceToPosition( Entity:GetPosition());

	local EntityState = Entity:GetState();

	-- Check if this routine is allowed to be ran under the current circumstances.
	if Entity:IsDead() or ( not Settings.Songweaver.AllowApproach and Range > 23 ) then
		return true;
	end

	-- Check if the entity requires healing and perform the correct healing routine.
	if Entity:GetHealth() < 80 and ( Settings.Songweaver.AllowApproach or Range <= 23 ) then

		-- Retrieve the local target for certain checks.
		local Target = EntityList:GetEntity( Player:GetTargetID());

		-- Change the healing routine if I'm healing myself when allowed to attack.
		if Entity:GetID() == Player:GetID() and Settings.Songweaver.AllowAttack then -- and Target ~= nil and not Target:IsDead() then
			if Entity:GetHealth() < 60 and Helper:CheckAvailable( "Gentle Echo" ) then
				Helper:CheckExecute( "Gentle Echo", Entity );
				return false;
			end
		-- Check if we should heal the provided entity.
		elseif Entity:GetHealth() < 70 and Helper:CheckAvailable( "Gentle Echo" ) then
			Helper:CheckExecute( "Gentle Echo", Entity );
			return false;
		end

	end

	--Chain Heal: Soft Echo
	if Helper:CheckAvailable( "Soft Echo" ) and Player:GetHealth() < 70 then
		Helper:CheckExecute( "Soft Echo" );
		return false;
	end


	--Chain Heal: Mild Echo
	if Helper:CheckAvailable( "Mild Echo" ) and Player:GetHealth() < 70 then
		Helper:CheckExecute( "Mild Echo" );
		return false;
	end

	-- Return true to let the caller know this function completed.
	return true;

end





---------------------------------------------------------------------------------------
---------------------!!!!!!!!! DO NOT TOUCH MANA HEALING!!!!!!!!!!!--------------------
---------------------------------------------------------------------------------------

--- Checks if the state of the provided entity.
--
-- @param	Entity	Contains the entity to check.
-- @return	bool

function _CheckMana( Entity )

	-- Retrieve the range of the entity compared to my own character position.
	local Range = Player:GetPosition():DistanceToPosition( Entity:GetPosition());

	local EntityState = Entity:GetState();

	-- Check if this routine is allowed to be ran under the current circumstances.
	if Entity:IsDead() or ( not Settings.Songweaver.AllowApproach and Range > 23 ) then
		return true;
	end

	-- Check if the entity requires healing and perform the correct healing routine.
	if Entity:GetMana() < 80 and ( Settings.Songweaver.AllowApproach or Range <= 23 ) then

		-- Retrieve the local target for certain checks.
		local Target = EntityList:GetEntity( Player:GetTargetID());

		-- Change the healing routine if I'm healing myself when allowed to attack.
		if Entity:GetID() == Player:GetID() and Settings.Songweaver.AllowAttack then -- and Target ~= nil and not Target:IsDead() then
			if Entity:GetMana() < 40 and Helper:CheckAvailable( "Echo of Elegance" ) then
				Helper:CheckExecute( "Echo of Elegance", Entity );
				return false;
			end
		-- Check if we should heal the provided entity.
		elseif Entity:GetMana() < 40 and Helper:CheckAvailable( "Echo of Elegance" ) then
			Helper:CheckExecute( "Echo of Elegance", Entity );
			return false;
		end

	end

	--Chain Heal: Soft Echo
	if Helper:CheckAvailable( "Pure Echo" ) and Player:GetMana() < 70 then
		Helper:CheckExecute( "Pure Echo" );
		return false;
	end


	--Chain Heal: Mild Echo
	if Helper:CheckAvailable( "Echo of Clarity" ) and Player:GetMana() < 90 then
		Helper:CheckExecute( "Echo of Clarity" );
		return false;
	end

	-- Return true to let the caller know this function completed.
	return true;

end
---------------------------------------------------------------------------------------





function _CheckState( Entity )

	-- Retrieve the range of the entity compared to my own character position.
	local Range = Player:GetPosition():DistanceToPosition( Entity:GetPosition());

	-- Check if this routine is allowed to be ran under the current circumstances.
	if Entity:IsDead() or ( not Settings.Songweaver.AllowApproach and Range > 23 ) then
		return true;
	end

	-- Retrieve the state for the current entity to inspect.
	local EntityState = Entity:GetState();

	-- Loop through the states only when we are available to dispel them. We still check for removed states!
	if EntityState ~= nil and ( self.StateDispelTime == nil or self.StateDispelTime < Time()) then

		-- Create the state array for the global entity storage and undispellable states if it does not exist.
		if self.StateArray == nil or self.StateUndispellable == nil then
			self.StateArray = {};
			self.StateUndispellable = {};
		end

		-- Create the state array for the current entity if it does not exist.
		if self.StateArray[Entity:GetID()] == nil then
			self.StateArray[Entity:GetID()] = {};
		end

		-- Loop through the states to find which need to be removed.
		for ID, Skill in DictionaryIterator( EntityState:GetList()) do

			-- Check if the current skill is valid and has not been marked and undispellable.
			if Skill ~= nil and Skill:IsDebuff() and ( self.StateUndispellable[Skill:GetID()] == nil or self.StateUndispellable[Skill:GetID()] < Time()) then

				-- Check if this entity had the current skill effect on him and hasn't been removed by either Cure Mind or Dispel.
				if self.StateArray[Entity:GetID()][Skill:GetID()] ~= nil and self.StateArray[Entity:GetID()][Skill:GetID()] == 2 then
					self.StateUndispellable[Skill:GetID()] = Time() + 30000;
				-- Remove the state from the entity.
				else

					-- Retrieve the magical state the current skill.
					local RemoveMagical = Skill:IsMagical();

					-- Check if we are required to change the magical state for the current skill.
					if self.StateArray[Entity:GetID()][Skill:GetID()] ~= nil then
						RemoveMagical = not RemoveMagical;
					end

					-- Check if the dispel or cure mind can be executed correctly. The function might need to set the target first!
					if ( RemoveMagical and Helper:CheckExecute( "Melody of Purification I", Entity )) or ( not RemoveMagical and Helper:CheckExecute( "Melody of Purification I", Entity )) then

						-- Change the state dispel timer to prevent dispel and cure mind from being used too quickly.
						self.StateDispelTime = Time() + 500;

						-- Track the current state of the dispel and cure mind to find undispellable states.
						if self.StateArray[Entity:GetID()][Skill:GetID()] == nil then
							self.StateArray[Entity:GetID()][Skill:GetID()] = 1;
							return false;
						else
							self.StateArray[Entity:GetID()][Skill:GetID()] = 2;
							return false;
						end

					end

				end

			end

		end

		-- Loop through the existing states to find which have been removed correctly.
		for k,v in pairs( self.StateArray[Entity:GetID()] ) do
			if v ~= nil and EntityState:GetState( k ) == nil then
				self.StateArray[Entity:GetID()][k] = nil;
			end
		end

	end

	-- Return true to let the caller know this function completed.
	return true;

end


-----Sleep second target
function CountMobs( EntityTarget, Distance )

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
					if EntityState:GetState( Helper:CheckName( "Dance of the Jester" )) ~= nil then
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
			if Helper:CheckAvailable( "Dance of the Jester" ) then
				-- Shoot the Sleep Arrow.
				Helper:CheckExecute( "Dance of the Jester" );
				-- Indicate we cannot continue attacking.
				return false;
			else
				-- Set the target.
				Player:SetTarget( self._SleepTargetRestore );
				-- Indicate we cannot continue attacking.
				return false;
			end
		-- Check if the current target is the original target.
		elseif not Helper:CheckAvailable( "Dance of the Jester" ) and self._SleepTargetRestore:GetID() == EntityTarget:GetID() then
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
	if Helper:CheckAvailable( "Dance of the Jester" ) then
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



-- Contains the multicast cooldown.
local MulticastCooldown = {}
-- Contains the multicast identifier.
local MulticastId = 0
-- Contains the multicast level.
local MulticastLevel = 0
-- Contains the multicast name.
local MulticastName = nil
-- Contains the multicast reuse.
local MulticastReuse = 0
-- Contains the multicast target level.
local MulticastTargetLevel = 0

--- Perform the attack routine on the selected target.
--
-- @param	Entity	Contains the entity we have targeted.
-- @param	double	Contains the distance to the target
-- @param	bool	Indicates whether or not the target is stunned.
-- @return	bool

function Attack( Entity, Range, Stunned )

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

	-----------------------------------


	---enemy position check
	local Position = Player:GetPosition();
	--
	local AttackRange = Player:GetAttackRange();
	--
	local EntityState = Entity:GetState();

	local PlayerState = Player:GetState();

	local CaptivateEffect = Entity:GetState():GetState( Helper:CheckName( "Captivate" ));



	-- Check if we are allowed to sleep attackers.
	if Settings.Songweaver.AllowSleep and not self:SleepMultipleAttacker( Entity, AttackRange ) then
		return false;
	end


	------------------------
	--- M U L T I C A S T---
	------------------------

	-- Check if a multicast level has been set.
	if MulticastLevel ~= 0 then
		-- Initialize the skill identifier.
		local Id = Player:GetSkillId()
		-- Check if the skill identifier is set.
		if Id ~= 0 then
			-- Check if the previous identifier is invalid.
			if MulticastId == 0 then
				-- Set the previous identifier.
				MulticastId = Id
			-- Otherwise check if the identifier has increased.
			elseif Id > MulticastId then
				-- Increment the multicast level.
				MulticastLevel = MulticastLevel + 1
				-- Set the previous identifier.
				MulticastId = Id
				-- Check if the desired multicast level has been achieved.
				if MulticastLevel == MulticastTargetLevel then
					-- End with the Fiery Descadent ability.
					self:Do(MulticastName)
					-- Set the cooldown for the multicast skill.
					MulticastCooldown[MulticastName] = Time() + MulticastReuse
					-- Reset the multicast level.
					MulticastLevel = 0
				end
			end
			-- Prevent other responsibilities.
			return false;
		end
	end



	-----------------------------------------
	-------------------Shock-----------------
	-----------------------------------------

	if Helper:CheckAvailable( "Shock Blast" ) then
		Helper:CheckExecute( "Shock Blast" );
	elseif Helper:CheckAvailable( "Melody of Appreciation" ) and Player:GetHealth() < 50 then
		Helper:CheckExecute( "Melody of Appreciation" );
		return false;
	end

	-----------------------------------------
	-----------------Bufovani----------------
	-----------------------------------------

	if Helper:CheckAvailable( "Shield Melody" ) and PlayerState:GetState( Helper:CheckName( "Shield Melody" )) == nil then
		Helper:CheckExecute( "Shield Melody" );
		return false;
	end

	--Melody of Reflection (Mana Recovery)
	if Helper:CheckAvailable( "Melody of Reflection" ) and Player:GetMana() < 50 then
		Helper:CheckExecute( "Melody of Reflection", Player );
		return false;
	end

	---------------------------------------------------
	------------------CHAIN ATTACKS--------------------
	---------------------------------------------------

	--Chain attack : Captivate -> Binding Blast
	if Helper:CheckAvailable( "Binding Blast" ) then
		Helper:CheckExecute( "Binding Blast" );
		return false;
	end

	--Chain attack : Wind Harmony + Earth Harmony
	if Helper:CheckAvailable( "Wind Harmony" ) then
		Helper:CheckExecute( "Wind Harmony" );
	elseif Helper:CheckAvailable( "Earth Harmony" ) then
		Helper:CheckExecute( "Earth Harmony" );
	elseif Helper:CheckAvailable( "Flame Harmony" ) then
		Helper:CheckExecute( "Flame Harmony" );
		return false;
	end


	--Chain attack : Fire Chord
	if Helper:CheckAvailable( "Fire Chord" ) then
		Helper:CheckExecute( "Fire Chord" );
		return false;
	end

	--Chain attack: Harmony of Silence + Harmony of Destruction
	if Helper:CheckAvailable( "Harmony of Silence" ) then
		Helper:CheckExecute( "Harmony of Silence" );
	elseif Helper:CheckAvailable( "Harmony of Destruction" ) then
		Helper:CheckExecute( "Harmony of Destruction" );
		return false;
	end

	--Chain attack: Harmony of Death
	if Helper:CheckAvailable( "Harmony of Death" ) then
		Helper:CheckExecute( "Harmony of Death" );
		return false;
	end

	--Chain attack: Tsunami Requiem
	if Helper:CheckAvailable( "Tsunami Requiem" ) then
		Helper:CheckExecute( "Tsunami Requiem" );
		return false;
	end


	-----------------------------------------
	--------------Primary Skills-------------
	-----------------------------------------

	---- Check if Battle Variation is ready for multicast and the target is not yet pissed.
	--if Entity:GetHealth() >= 0 and Position:DistanceToPosition( Entity:GetPosition()) >= 16 and self:Multicast("Sea Variation", 3, Entity) then
	---- Prevent other responsibilities.
	--	return false;
	--end


	-- Check if Battle Variation is ready for multicast and the target is not yet pissed.
	--if Entity:GetHealth() >= 0 and Position:DistanceToPosition( Entity:GetPosition()) >= 16 and self:Multicast("Battle Variation", 3, Entity) then
	-- Prevent other responsibilities.
	--	return false;
	--end

	-- Check if Battle Variation is ready for multicast and the target is not yet pissed.
	--if Entity:GetHealth() >= 0 and Position:DistanceToPosition( Entity:GetPosition()) >= 16 and self:Multicast("Ascended Soul Variation", 3, Entity) then
	-- Prevent other responsibilities.
	--	return false;
	--end

	if Helper:CheckAvailable( "Pure Echo" ) then
		Helper:CheckExecute( "Pure Echo" );
		return false;
	end

	if Helper:CheckAvailable( "Echo of Clarity" ) then
		Helper:CheckExecute( "Echo of Clarity" );
		return false;
	end

	if Player:GetManaCurrent() < 6000 and Helper:CheckAvailable( "Echo of Elegance" ) then
	 	Helper:CheckExecute( "Echo of Elegance" );
	  	self.PerformFlash = nil;
			return false;
	end

	if Helper:CheckAvailable( "March of the Bees" ) then
		Helper:CheckExecute( "March of the Bees" );
		return false;
	end

	if Helper:CheckAvailable( "Disharmony" ) then
		Helper:CheckExecute( "Disharmony" );
		return false;
	end

	--Immobilize : Captivate
	if Position:DistanceToPosition( Entity:GetPosition()) >= 8 and Helper:CheckAvailable( "Captivate" ) then
		Helper:CheckExecute( "Captivate", Entity );
		return false;
	end

	-- 2000DP Skill Symphony of Wrath , Symphony of Destruction
	if Helper:CheckAvailable( "Symphony of Wrath" ) and Player:GetDP() >=2000 then
		Helper:CheckExecute( "Symphony of Wrath");
	elseif Helper:CheckAvailable( "Symphony of Destruction" ) and Player:GetDP() >=2000 then
		Helper:CheckExecute( "Symphony of Destruction");
		return false;
	end


	-- Attack : Chilling Harmony
	if Helper:CheckAvailable( "Chilling Harmony" ) then
		Helper:CheckExecute( "Chilling Harmony" );
		return false;
	end

	-- Attack : Loud Bang
	--if Position:DistanceToPosition( Entity:GetPosition()) >= 5 and Helper:CheckAvailable( "Loud Bang" ) then
	--	Helper:CheckExecute( "Loud Bang", Entity );
	--	return false;
	--end

	-- Attack : Loud Bang
	if Helper:CheckAvailable( "Loud Bang" ) then
		Helper:CheckExecute( "Loud Bang" );
		return false;
	end


	-- Attack : Acute Grating Sound
	if Helper:CheckAvailable( "Acute Grating Sound" ) then
		Helper:CheckExecute( "Acute Grating Sound" );
		return false;
	end

	-- Attack : Gust Requiem
	if Helper:CheckAvailable( "Gust Requiem" ) then
		Helper:CheckExecute( "Gust Requiem" );
		return false;
	end

	-- Attack : Soul Harmony
	if Helper:CheckAvailable( "Soul Harmony" ) then
		Helper:CheckExecute( "Soul Harmony" );
		return false;
	end

	-- Attack Sound of the Breeze
	if Helper:CheckAvailable("Sound of the Breeze") then
		Helper:CheckExecute("Sound of the Breeze" )
		return false;
	end

	-- Initial Attack : Automatic Attack
	if self.AttackStarted ~= Entity:GetID() then
		self.AttackStarted = Entity:GetID();
		Helper:CheckExecute( "Attack/Chat" );
		return false;
	end


	if Player:GetManaCurrent() < 8000 and Helper:CheckAvailable( "Melody of Reflection" ) then
	 	Helper:CheckExecute( "Melody of Reflection" );
	  	self.PerformFlash = nil;
			return false;
	end


end

	--
	-- Perform an ability without condition checking.
	--
	function Do(Name)
		-- Find the ability with the specified name.
		local Ability = AbilityList:GetAbility(Name)
		-- Check if the ability is valid.
		if Ability ~= nil then
			-- Input the command to do the ability.
			PlayerInput:Console("/Skill " .. Ability:GetName())
		end
	end

	--
	-- Begin a multicast ability.
	--
	function Multicast(Name, TargetLevel)
		-- Initialize the ability.
		local Ability = AbilityList:GetAbility(Name)
		-- Check if the ability is available.
		if Ability ~= nil then
			-- Check if the multicast ability is not available.
			if MulticastCooldown[Ability:GetName()] ~= nil and MulticastCooldown[Ability:GetName()] >= Time() then
				-- Return false.
				return false;
			-- Otherwise execute the multicast ability.
			elseif Helper:CheckExecute(Ability:GetName()) then
				-- Initialize the multicast identifier.
				MulticastId = 0
				-- Initialize the multicast level.
				MulticastLevel = 1
				-- Initialize the multicast name.
				MulticastName = Ability:GetName()
				-- Initialize the multicast reuse.
				MulticastReuse = Ability:GetReuse()
				-- Initialize the multicast target level.
				MulticastTargetLevel = TargetLevel
				-- Return true.
				return true
			end
		end
		-- Return false.
		return false
	end


--- Perform healing checks both in and our of combat.
--
-- @param	bool	Indicates whether or not the function is running before force checks.
-- @return	bool

function Heal( BeforeForce )

	if BeforeForce and Settings.Songweaver.AllowBuff and ( self.StateBuffTime == nil or self.StateBuffTime < Time()) then

		local EntityState = Player:GetState();

		if EntityState ~= nil then

			-- Check if this entity has the Blessing of Health state.
			--if Helper:CheckAvailable( "Melody of Life I" ) and EntityState:GetState( "Melody of Life I" ) == nil and EntityState:GetState( "Melody of Life II" ) == nil and EntityState:GetState( "Blessing of Health I" ) == nil and EntityState:GetState( "Blessing of Health II" ) == nil and EntityState:GetState( "Blessing of Growth" ) == nil then
			--	Helper:CheckExecute( "Melody of Life", Entity );
			--	return false;
			--end


		end
	end

	-- Check if we are allowed to execute our healing routines, after checking the force we can check our own HP.
	if not BeforeForce and Settings.Songweaver.AllowHealing then

		-- Check the required direct healing for my own character.
		if not self:_CheckHeal( Player ) then
			return false;
		end

	end

	-- Check if we are allowed to execute our healing routines, after checking the force we can check our own HP.
	if not BeforeForce and Settings.Songweaver.AllowHealingMana then

		-- Check the required direct healing for my own character.
		if not self:_CheckMana( Player ) then
			return false;
		end

	end

	-- Nothing was executed, continue with other functions.
	return true;

end

function Pause()

	--------chain--------
	if Helper:CheckAvailable( "Echo of Clarity" ) then
		Helper:CheckExecute( "Echo of Clarity" );
		return false;
	end

	--Melody of Reflection (Mana Recovery)
	if Helper:CheckAvailable( "Echo of Elegance" ) and Player:GetMana() < 85 then
		Helper:CheckExecute( "Echo of Elegance", Player );
		return false;
	end

	if Helper:CheckAvailable( "Gentle Echo" ) and Player:GetHealth() < 85 then
		Helper:CheckExecute( "Gentle Echo", Player );
		return false;
	end
	-- Nothing was executed, continue with other functions.
	return true;

end

---------------Bufovani-------------
function CheckCritFood()

stateID = {10224,10225,9976,9989,10051,10064};
foodName = {"Calydon Meat Dumpling","Wild Ginseng Pickle","Tasty Calydon Meat Dumpling","Tasty Wild Ginseng Pickle","Innesi Herb Dumpling","Poma Wine Herb Dumpling","Tasty Innesi Herb Dumpling","Tasty Poma Wine Herb Dumpling"};
flag = 0;

    for _,v in ipairs(stateID) do
        if Player:GetState():GetState( v ) ~= nil then
            flag = flag + 1;
        end
    end

    if flag == 0 then
        for a,b in ipairs(foodName) do
            if Helper:CheckAvailableInventory( b ) then
                PlayerInput:Inventory( b );
                break;
            end
        end
    end


return true;
end

--------------------------------
function CheckAttackFood()

stateID = {10051,10064,10224,10225,9976,9989};
foodName = {"Minor Focus Agent","Lesser Focus Agent","Focus Agent","Greater Focus Agent","Major Focus Agent","Fine Focus Agent"};
flag = 0;

    for _,v in ipairs(stateID) do
        if Player:GetState():GetState( v ) ~= nil then
            flag = flag + 1;
        end
    end

    if flag == 0 then
        for a,b in ipairs(foodName) do
            if Helper:CheckAvailableInventory( b ) then
                PlayerInput:Inventory( b );
                break;
            end
        end
    end
return true;


end
-----------------------------------
function CheckNaturalHeal()

stateID = {10044,10094};
foodName = {"Minor Rally Serum","Lesser Rally Serum","Rally Serum","Greater Rally Serum","Major Rally Serum","Fine Rally Serum","Tasty Ormea Cocktail"};
flag = 0;

    for _,v in ipairs(stateID) do
        if Player:GetState():GetState( v ) ~= nil then
            flag = flag + 1;
        end
    end

    if flag == 0 then
        for a,b in ipairs(foodName) do
            if Helper:CheckAvailableInventory( b ) then
                PlayerInput:Inventory( b );
                break;
            end
        end
    end
return true;

end
-------------------------------------
function CheckAttackScroll()

stateID = {9959};
foodName = {"Greater Courage Scroll"};
flag = 0;

    for _,v in ipairs(stateID) do
        if Player:GetState():GetState( v ) ~= nil then
            flag = flag + 1;
        end
    end

    if flag == 0 then
        for a,b in ipairs(foodName) do
            if Helper:CheckAvailableInventory( b ) then
                PlayerInput:Inventory( b );
                break;
            end
        end
    end
return true;

end
--------------------------
function CheckRunScroll()

stateID = {9960};
foodName = {"Greater Running Scroll"};
flag = 0;

    for _,v in ipairs(stateID) do
        if Player:GetState():GetState( v ) ~= nil then
            flag = flag + 1;
        end
    end

    if flag == 0 then
        for a,b in ipairs(foodName) do
            if Helper:CheckAvailableInventory( b ) then
                PlayerInput:Inventory( b );
                break;
            end
        end
    end
return true;

end

