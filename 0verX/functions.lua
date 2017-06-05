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

--- Check if the provided ability is available and has cooled down.
--
-- @param	string	Name of the ability to check.
-- @param	bool	Indicates whether or not to skip the activation check.
-- @return	boolean

function CheckAvailable( Name, SkipActivation )

	-- Retrieve the ability with the provided name.
	local Ability = Helper:GetAbility( Name );

	-- Check if the ability is valid and is not in cooldown.
	if Ability ~= nil and Ability:GetCooldown() == 0 and ( SkipActivation ~= nil or Ability:GetActivated()) then
		return true;
	end

	-- Either we do not have the ability or it is in cooldown.
	return false;
	
end

--- Check if the provided inventory is available and has cooled down.
--
-- @param	string	Name of the inventory to check.
-- @param	integer	Contains the amount required to check, instead of a valid cooldown.
-- @return	boolean

function CheckAvailableInventory( Name, Amount )

	-- Retrieve the item with the provided name.
	local Inventory = InventoryList:GetInventory( Name );

	-- Check if the item is valid and is not in cooldown.
	if Inventory ~= nil and (( Amount == nil and Inventory:GetCooldown() == 0 ) or ( Amount ~= nil and Inventory:GetAmount() >= Amount )) then
		return true;
	end

	-- Either we do not have the item or it is in cooldown.
	return false;
	
end

--- Checks if the target we have matches the conditions to cast friendly magic.
--
-- @param	Entity	Contains the entity to match the target on.
-- @param	bool	Indicates whether or not this is a hostile spell.
-- @return	bool

function CheckExecute( Name, Entity )

	-- Retrieve the ability with the provided name.
	local Ability = Helper:GetAbility( Name );
	
	-- Check if the provided ability is available and return when it is not.
	if Ability == nil or Ability:GetCooldown() ~= 0 then
		return false;
	end
	
	-- Check if I am currently resting and stop resting when I am!
	if Player:IsResting() then
		PlayerInput:Ability( "Toggle Rest" );
		return false;
	end
	
	-- Check if this is a friendly ability with my own character as the target.
	if Entity ~= nil and Player:GetID() == Entity:GetID() then
		
		-- Retrieve the skill based on the ability identifier.
		local Skill = SkillList:GetSkill( Ability:GetID());
	
		-- It is not possible to perform a hostile skill on my own character.
		if Skill == nil or Skill:IsAttack() then
			return false;
		end
		
		-- When no target has been selected we can execute the ability.
		if Player:GetTargetID() == 0 then
			return PlayerInput:Ability( Name );
		end
		
		-- Otherwise retrieve the entity we currently have selected.
		local EntityTarget = EntityList:GetEntity( Player:GetTargetID());
		
		-- When the target is valid and is not friendly we can use our ability.
		if EntityTarget ~= nil and not EntityTarget:IsFriendly() then
			return PlayerInput:Ability( Name );
		end
		
	end

	-- Check if the target entity has been selected and select it when it is needed.
	if Entity ~= nil and Player:GetTargetID() ~= Entity:GetID() then
		Player:SetTarget( Entity );
		return false;
	end
	
	-- Everything seems to be valid 
	return PlayerInput:Ability( Name );
	
end

--- Checks if the provided Entity has one of the known reflection-based states.
--
-- @param	Entity	Contains the entity to check for reflect.
-- @return	bool

function CheckMelee()

	-- Retrieve the class of the current character.
	local Class = Player:GetClass():ToString();
	
	-- Check if the class is a focused melee-orientated class.
	if Class == "Assassin" or Class == "Chanter" or Class == "Gladiator" or Class == "Ranger" or Class == "Templar" then
		return true;
	end
	
	-- Otherwise return false, since we are a magical-based class.
	return false;
	
end
--- Check if the provided ability is available and return the full name.
--
-- @param	string	Name of the ability to check.
-- @return	boolean

function CheckName( zName )

	-- Get the ability with the provided name.
	local Ability = Helper:GetAbility( zName );
	
	-- Check if the ability is valid (you have learned it) and 
	if Ability ~= nil then
		return Ability:GetName();
	end
	
	-- We do not have the ability, return nothing.
	return nil;
	
end

--- Checks if the provided Entity has one of the known reflection-based states.
--
-- @param	Entity	Contains the entity to check for reflect.
-- @return	bool

function CheckReflect( Entity )

	-- Check if the provided entity is valid.
	if Entity == nil then
		return false;
	end 
	
	-- Retrieve the state for this entity to check for known reflect states.
	local EntityState = Entity:GetState();
	
	-- Check if the retrieved entity state is valid.
	if EntityState == nil then
		return false;
	end
	
	-- Check the list of known reflection states.
	if EntityState:GetState( "Stigma: Protection" ) ~= nil
		or EntityState:GetState( "Punishment" ) ~= nil
		or EntityState:GetState( "Nightmare" ) ~= nil
		or EntityState:GetState( "Wintry Armor" ) ~= nil
		or EntityState:GetState( "Fatal Reflection" ) ~= nil
		or EntityState:GetState( "Reflect" ) ~= nil
		or EntityState:GetState( "Reflective Shield" ) ~= nil
		or EntityState:GetState( "Seal of Reflection" ) ~= nil
		or EntityState:GetState( "Shield of Reflection" ) ~= nil
		or EntityState:GetState( "Strike of Protection" ) ~= nil
		or EntityState:GetState( "Blade Storm" ) ~= nil then
		return true;
	end
	
	-- None of the known reflection 
	return false;
	
end


function CheckScroll(Name)

    local Inventory = InventoryList:GetInventory(Name);
        if Inventory ~= nil and Inventory:GetType():ToString() == "Scroll" then
            return true;
        end
return false;
end

local LocalAbilityLookup = {}

function GetAbility(Name)

   local lookupResult = LocalAbilityLookup[Name];

   if lookupResult ~= nil then
      return lookupResult;
   end
   
   local Ability = AbilityList:GetAbility( Name );

   if Ability == nil then
      return nil;
   end

   if Player:GetLevel() == 65 then
      -- we are max level, find the highest level version of the skill
      local foundAbility = Ability;
      local found = true;
      local currentId = Ability:GetID();
      local maxLevel = Ability:GetLevel();
      
      -- go forward
      while (found)
      do
         currentId = currentId + 1;
         local AbilityTest = AbilityList:GetAbility(currentId);
         --Write('AbilityTest:: look up of id: ' .. currentId .. ', result: ' .. (AbilityTest ~= nil and ('' .. AbilityTest:GetName() .. ', id: ' .. AbilityTest:GetID() .. ', level: ' .. AbilityTest:GetLevel()) or 'nil'));
         
         if AbilityTest == nil then -- sometimes we need to skip an id
            currentId = currentId + 1;
            AbilityTest = AbilityList:GetAbility(currentId);
         end
         
         if AbilityTest ~= nil and Ability:GetName() == AbilityTest:GetName() then
            --Write('AbilityTest:: name:' .. AbilityTest:GetName() .. ', id: ' .. AbilityTest:GetID() .. ', level: ' .. AbilityTest:GetLevel());
            if AbilityTest:GetLevel() >= maxLevel then
               foundAbility = AbilityTest;
               maxLevel = AbilityTest:GetLevel();
            end
            found = true;
         else
            found = false;
         end
      end
      
      -- go backwards
      found = true;
      currentId = Ability:GetID();
      while (found)
      do
         currentId = currentId - 1;
         local AbilityTest = AbilityList:GetAbility(currentId);
         --Write('AbilityTest:: look up of id: ' .. currentId .. ', result: ' .. (AbilityTest ~= nil and ('' .. AbilityTest:GetName() .. ', id: ' .. AbilityTest:GetID() .. ', level: ' .. AbilityTest:GetLevel()) or 'nil'));
         
         if AbilityTest == nil then -- sometimes we need to skip an id
            currentId = currentId - 1;
            AbilityTest = AbilityList:GetAbility(currentId);
         end
         
         if AbilityTest ~= nil and Ability:GetName() == AbilityTest:GetName() then
            --Write('AbilityTest:: name:' .. AbilityTest:GetName() .. ', id: ' .. AbilityTest:GetID() .. ', level: ' .. AbilityTest:GetLevel());
            if AbilityTest:GetLevel() >= maxLevel then
               foundAbility = AbilityTest;
               maxLevel = AbilityTest:GetLevel();
            end
            found = true;
         else
            found = false;
         end
      end
      
      Ability = foundAbility;
      Write('found Ability (' .. Name .. '), name: ' .. Ability:GetName() .. ', id: ' .. Ability:GetID() .. ', level: ' .. Ability:GetLevel());
   else
      -- work around for off-by-one bug regarding multi level skills
      local abilityId = Ability:GetID();
      local AbilityP1 = AbilityList:GetAbility(abilityId + 1);
      if AbilityP1 ~= nil and AbilityP1:GetName() == Ability:GetName() then
         -- seems Summon Cyclone Servant needs has 12 entries for 6 levels ?
         local abilityIdNext = abilityId + 1;
         local AbilityNext = AbilityP1;
         
         if Name == "Summon Cyclone Servant" or Name == "Summon Wind Servant" or Name == "Glacial Shard" then
            local foundNext = true;
            while (foundNext)
            do
               abilityIdNext = abilityIdNext + 1;
               local AbilityTest = AbilityList:GetAbility(abilityIdNext);
               if AbilityTest ~= nil and Ability:GetName() == AbilityTest:GetName() then
                  AbilityNext = AbilityTest;
                  foundNext = true;
               else
                  foundNext = false;
               end
            end
         end
         
         Ability = AbilityNext;
      end
   end
   
   LocalAbilityLookup[Name] = Ability;

   return Ability;
end

function FindTarget( Restricted, Position, Distance, Priority )

	-- Prepare the variables to contain the list, best entity and distance.
	
	local BestEntity = nil;
	local BestDistance = 0;

	-- Check if a position has been provided and use the starting position when this is not the case.
	if Position == nil then
		Position = self._PositionStart;
	end

	-- Check if a position has been provided and use the starting position when this is not the case.
	if Distance == nil then
		if Restricted then
			Distance = 30;
		else
			Distance = Settings.TargetSearchDistance;
		end
	end

	-- Loop through the available entities to find the spirit.
	for ID, Entity in DictionaryIterator( EntityList:GetList()) do

		-- Check if this monster is in the maximum range from the starting position, if is a proper monster and if it is alive.
		if (  Entity:GetId() ~= self._LosIdSkip or Entity:GetTargetId() == Player:GetId()) and Entity:IsMonster() and not Entity:IsFriendly() and not Entity:IsDead() and not Entity:IsObject() and not Entity:IsHidden() then

			if Entity:GetPosition():DistanceToPosition( Player:GetPosition()) < 15 then
			
				-- Check if this monster is not engaged in combat with another player. This is skipped when searching for attackers only!
				if not Priority and ( Restricted == nil or Restricted == false ) and ( Entity:GetTargetID() == 0 or Entity:GetTargetID() == Entity:GetID() or ForceList:GetForce( Entity:GetTargetID()) ~= nil ) then

				
					
						-- Calculate the distance from my position to the target entity.
						local CurrentDistance = Player:GetPosition():DistanceToPosition( Entity:GetPosition());
						
						-- Check if the monster is hostile, in which case it gets a higher priority due to it attacking us when near.
						if Entity:IsHostile() then
							CurrentDistance = CurrentDistance - 10;
						end
						
						-- Check if this entity is closer than the previous monster and remember it when it is.
						if BestDistance == 0 or BestDistance > CurrentDistance then
							BestDistance = CurrentDistance
							BestEntity = Entity;
						end
						
					end
					
				-- Check if this monster has targeted me and assign the highest priority on it!
				elseif Entity:GetTargetID() == Player:GetID() and BestDistance > -10 then
					BestEntity = Entity;
					BestDistance = -10;
				-- Check if this monster has targeted my spirit (if it is available), which will be the second highest priority!
				elseif EntitySpirit ~= nil and Entity:GetTargetID() == EntitySpirit:GetID() and BestDistance > -5 then
					BestEntity = Entity;
					BestDistance = -5;
				
				end
			
		end
		
	end

	-- Return the best entity match we have found.
	return BestEntity;
	
end


function CheckMelee()

	-- Retrieve the class of the current character.
	local Class = Player:GetClass():ToString();
	
	-- Check if the class is a focused melee-orientated class.
	if Class == "Assassin" or Class == "Chanter" or Class == "Gladiator" or Class == "Ranger" or Class == "Templar" then
		return true;
	end
	
	-- Otherwise return false, since we are a magical-based class.
	return false;
	
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