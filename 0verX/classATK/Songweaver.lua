--[[

	--------------------------------------------------
	Copyright (C) 2017 Locatelli

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
		-- local Target = EntityList:GetEntity( Player:GetTargetID());

    --Complete the Chain
    if Entity:GetID() == Player:GetID() and Settings.Songweaver.AllowAttack then
      if Entity:GetHealth() < 90 and Helper:CheckAvailable( "Melody of Joy" ) then
        Helper:CheckExecute ( "Melody of Joy", Entity )
        return false;
      elseif Entity:GetHealth() < 90 and Helper:CheckAvailable( "Soft Echo" ) then
        Helper:CheckExecute ( "Soft Echo", Entity )
        return false;
      elseif Entity:GetHealth() < 90 and Helper:CheckAvailable( "Mild Echo" ) then
        Helper:CheckExecute ( "Mild Echo", Entity )
        return false;
      end
    end
    
		-- Change the healing routine if I'm healing myself when allowed to attack.
		if Entity:GetID() == Player:GetID() and Settings.Songweaver.AllowAttack then  --and Target ~= nil and not Target:IsDead() then
			if Entity:GetHealth() < 50 and Helper:CheckAvailable( "Gentle Echo" ) then
				Helper:CheckExecute( "Gentle Echo", Entity );
				return false;
			end
		-- Check if we should heal the provided entity.
		elseif Entity:GetHealth() < 40 and Helper:CheckAvailable( "Gentle Echo" ) then
			Helper:CheckExecute( "Gentle Echo", Entity );
			return false;
		end

	end
	
	--Heal: Rejuvenation Melody
	if Helper:CheckAvailable( "Rejuvenation Melody" ) and Entity:GetHealth() < 60 then
		Helper:CheckExecute( "Rejuvenation Melody", Entity );
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
  
  --Complete the Chain
  if Player:GetMana() < 90 and Helper:CheckAvailable( "Variation of Peace" ) then
    Helper:CheckExecute ( "Variation of Peace" )
    return false;
  end

	-- Check if the entity requires healing and perform the correct mana healing routine.
	if Entity:GetMana() < 50 and ( Settings.Songweaver.AllowApproach or Range <= 23 ) then
    if Entity:GetMana() < 45 and Helper:CheckAvailable( "Echo of Clarity" ) then
      Helper:CheckExecute( "Echo of Clarity", Entity )
      return false;
    end
  end
  
  if Player:GetMana() < 50 and Helper:CheckAvailable( "Melody of Reflection" ) then
    Helper:CheckExecute( "Melody of Reflection" )
    return false;
  end

	-- Return true to let the caller know this function completed.
	return true;

end
--------------------------------------------------------------------------------------


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
					if ( RemoveMagical and Helper:CheckExecute( "Melody of Purification", Entity )) or ( not RemoveMagical and Helper:CheckExecute( "Melody of Purification", Entity )) then

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
					if EntityState:GetState( Helper:CheckName( "March of the Jester" )) ~= nil then
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
			if Helper:CheckAvailable( "March of the Jester" ) then
				-- Shoot the Sleep Arrow.
				Helper:CheckExecute( "March of the Jester" );
				-- Indicate we cannot continue attacking.
				return false;
			else
				-- Set the target.
				Player:SetTarget( self._SleepTargetRestore );
				-- Indicate we cannot continue attacking.
				return false;
			end
		-- Check if the current target is the original target.
		elseif not Helper:CheckAvailable( "March of the Jester" ) and self._SleepTargetRestore:GetID() == EntityTarget:GetID() then
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
	if Helper:CheckAvailable( "March of the Jester" ) then
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


--- Perform the attack routine on the selected target.
--
-- @param	Entity	Contains the entity we have targeted.
-- @param	double	Contains the distance to the target
-- @param	bool	Indicates whether or not the target is stunned.
-- @return	bool

function Attack( Entity, Range, Stunned )

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

	-----------------------------------------
	-------------------Shock-----------------
	-----------------------------------------
	
	-- Use Remove Shock
	if Helper:CheckAvailable( "Remove Shock" ) then
		Helper:CheckExecute( "Remove Shock" );
		return false;
	end
	
	-- Finish the Chain
  if Helper:CheckAvailable( "Melody of Appreciation" ) and Player:GetHealth() < 50 then
		Helper:CheckExecute( "Melody of Appreciation" );
		return false;
	elseif Helper:CheckAvailable( "Shock Blast" ) then
		Helper:CheckExecute( "Shock Blast" );
		return false;
	end
  
    -----------------------------------------
	--------------Wind Harmony---------------
	-----------------------------------------
  
	-- Wind Hrmony Buff Check here for best farming speed!
	if Helper:CheckAvailable( "Wind Harmony" ) and Helper:CheckAvailable ( "Chilling Harmony" ) then
      Helper:CheckExecute( "Chilling Harmony" )
      return false;
    end
  
  -----------------------------------------
	-------------Chain Completer-------------
	-----------------------------------------
  
  -- Charged Skills
	if Helper:CheckAvailable( "Tsunami Requiem" ) then
		Helper:CheckExecute( "Tsunami Requiem" );
		return false;
	end
	
	-- Chilling Harmony
	if Helper:CheckAvailable ( "Wind Harmony" ) then
      Helper:CheckExecute( "Wind Harmony" )
      return false;
    elseif Helper:CheckAvailable( "Earth Harmony" ) then
      Helper:CheckExecute( "Earth Harmony" );
      return false;
    elseif Helper:CheckAvailable( "Flame Harmony" ) then
      Helper:CheckExecute( "Flame Harmony" );
      return false;
    end
  
  -- Soul Harmony
  if Helper:CheckAvailable( "Harmony of Destruction" ) then
		Helper:CheckExecute( "Harmony of Destruction" );
		return false;
	elseif Helper:CheckAvailable( "Harmony of Death" ) then
		Helper:CheckExecute( "Harmony of Death" );
		return false;
  end
  
  -- Attack Resonation
  if Helper:CheckAvailable( "Acute Grating Sound" ) then
		Helper:CheckExecute( "Acute Grating Sound" );
		return false;
  end
  
	-----------------------------------------
	-----------------Bufovani----------------
	-----------------------------------------

	-- Emergency!: Snowflower Melody
	if Helper:CheckAvailable( "Snowflower Melody" ) and Player:GetHealth() < 40 then
		Helper:CheckExecute( "Snowflower Melody" );
		return false;
	end

	-- Shield Melody
	if Helper:CheckAvailable( "Shield Melody" ) and PlayerState:GetState( "Shield Melody" ) == nil then
		Helper:CheckExecute( "Shield Melody" );
		return false;
	end
	
	-- Buff: Melody of Cheer
	if Helper:CheckAvailable( "Melody of Cheer" ) and Entity:GetHealth() < 90 then
		Helper:CheckExecute( "Melody of Cheer" );
		return false;
	end	
	    
	-----------------------------------------
	--------------Primary Skills-------------
	-----------------------------------------

	-- Harmony of Silence
	if Helper:CheckAvailable( "Harmony of Silence" ) and Entity:GetSkillID() ~= 0 and SkillList[Entity:GetSkillID()]:IsMagical() and Entity:GetSkillTime() >= 500 then
		Helper:CheckExecute( "Harmony of Silence" );
		return false;
	end
	
	-- Fantastic Variation
	if Entity:GetHealth() >= 90 and Helper:CheckAvailable( "Fantastic Variatio" ) and Position:DistanceToPosition( Entity:GetPosition()) >= 12 then
		Helper:CheckExecute( "Fantastic Variation" );
		return false;
	end
  
  -- Illusion Variation
	if Entity:GetHealth() >= 90 and Helper:CheckAvailable( "Illusion Variation" ) and Position:DistanceToPosition( Entity:GetPosition()) >= 12 then
		Helper:CheckExecute( "Illusion Variation" );
		return false;
	end
	
	-- Battle Variation
	if Entity:GetHealth() >= 0 and Helper:CheckAvailable( "Battle Variation" ) and Helper:CheckAvailable( "Tsunami Requiem" ) and Position:DistanceToPosition( Entity:GetPosition()) >= 12 then
		Helper:CheckExecute( "Battle Variation");
		return false;
	end
	
	-- Ascended Soul Variation
	if Entity:GetHealth() >= 90 and Helper:CheckAvailable( "Ascended Soul Variation" ) and Position:DistanceToPosition( Entity:GetPosition()) >= 12 then
		Helper:CheckExecute( "Ascended Soul Variation" );
		return false;
	end
	
	-- Sea Variation
	if Entity:GetHealth() >= 90 and Helper:CheckAvailable( "Sea Variation" ) and Position:DistanceToPosition( Entity:GetPosition()) >= 12 then
		Helper:CheckExecute( "Sea Variation" );
		return false;
	end
		
  -- 2000DP Skill Symphony of Wrath , Symphony of Destruction
	if Helper:CheckAvailable( "Symphony of Destruction" ) and Player:GetDP() >=2000 then
		Helper:CheckExecute( "Symphony of Destruction");
		return false;
	end

	-- DOT Attack : Attack Resonation
	if Entity:GetHealth() >= 80 and Helper:CheckAvailable( "Attack Resonation" ) and Entity ~= nil then
		Helper:CheckExecute( "Attack Resonation" );
		return false;
	end

	-- Chain : Chilling Harmony
	if Helper:CheckAvailable( "Chilling Harmony" ) then
		Helper:CheckExecute( "Chilling Harmony" );
		return false;
	end	
	
	-- Attack : Loud Bang
	if Helper:CheckAvailable( "Loud Bang" ) then
		Helper:CheckExecute( "Loud Bang" );
		return false;
	end
	
	-- 2000 DP Skill Symphony of Wrath 
	if Helper:CheckAvailable( "Symphony of Wrath" ) and Player:GetDP() >=2000 then
		Helper:CheckExecute( "Symphony of Wrath");
		return false;
	end

	--  Attack : Disharmony
	if Entity:GetHealth() >= 25 and Helper:CheckAvailable( "Disharmony" ) then
		Helper:CheckExecute( "Disharmony" );
	end	
	
	-- DOT Attack : Mosky Requiem
	if Entity:GetHealth() >= 80 and Helper:CheckAvailable( "Mosky Requiem" ) then
		Helper:CheckExecute( "Mosky Requiem" );
		return false;
	end
	
    -- Attack : Gust Requiem
	if Helper:CheckAvailable( "Gust Requiem" ) then
		Helper:CheckExecute( "Gust Requiem" );
		return false;
	end

	--Attack : March of the Bees
	if Helper:CheckAvailable( "March of the Bees" ) then
		Helper:CheckExecute( "March of the Bees" );
		return false;
	end
	--Chain attack: Harmony of Death
	if Helper:CheckAvailable( "Soul Harmony" ) then
		Helper:CheckExecute( "Soul Harmony" );
		return false;
	end
	
	-- Attack : Sound of the Breeze
	if Helper:CheckAvailable( "Sound of the Breeze" ) then
		Helper:CheckExecute( "Sound of the Breeze" );
		return false;
	end
	
	-- Initial Attack : Automatic Attack
	if self.AttackStarted ~= Entity:GetID() then
		self.AttackStarted = Entity:GetID();
		Helper:CheckExecute( "Attack/Chat" );
		return false;
	end

end

	
--- Perform healing checks both in and our of combat.
--
-- @param	bool	Indicates whether or not the function is running before force checks.
-- @return	bool

function Heal( BeforeForce )

	if BeforeForce and Settings.Songweaver.AllowBuff and ( self.StateBuffTime == nil or self.StateBuffTime < Time()) then

		local EntityState = Player:GetState();

		if EntityState ~= nil then
			if EntityState:GetState( "Melody of Life" ) == nil and Helper:CheckAvailable( "Melody of Life" ) then
			Helper:CheckExecute( "Melody of Life",  Entity )
			end
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

--- Perform the safety checks before moving to the next target.
--
-- @return	bool

function Pause()
  
  --self:_CheckHeal ( Player )
  --self:_CheckMana ( Player )
  
	-- Nothing was executed, continue with other functions.
	return true;

end