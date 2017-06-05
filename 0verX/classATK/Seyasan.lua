--[[

	--------------------------------------------------
	Copyright (C) 2011 agonic & Blastradius & macrokor

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

--- Perform the attack routine on the selected target.
--
-- @param	StateList Contains the state list of the target entity.
-- @return	int

function _CheckRunes( EntityState )

	if EntityState ~= nil then
		-- Using numeric identifiers because there are multiple entries of this kind of skill,
		-- one for monsters and one for players. We're interested only in what we do, and unfortunately,
		-- this is the second entry.
		if EntityState:GetState( 8307 ) ~= nil then
			return 5;
		elseif EntityState:GetState( 8306 ) ~= nil then
			return 4;
		elseif EntityState:GetState( 8305 ) ~= nil then
			return 3;
		elseif EntityState:GetState( 8304 ) ~= nil then
			return 2;
		elseif EntityState:GetState( 8303 ) ~= nil then
			return 1;
		end
	end
	
	return 0;
	
end

--- Perform the attack routine on the selected target.
--
-- @param	Entity	Contains the entity we have targeted.
-- @param	double	Contains the distance to the target
-- @param	bool	Indicates whether or not the target is stunned.
-- @return	bool

function Attack( Entity, Range, Stunned )
	
	Entity_ = Entity;
	-- Check if we are a melee orientated class and the target has reflect!
	-- NOTE: Removed CheckMelee, so even Sorcerers will take a break here. Some reason, that didn't work.. no clue why!
	
	----------------------------------------------
	------------------ContRanged Buffs----------------
	----------------------------------------------
		-- Retrieve the entity state.
		local EntityState = Entity_:GetState();
		
		-- Retrieve the rune level on the target.
		local Runes = self:_CheckRunes( EntityState );
	
		-- Stunned is overwritten with Spin, but Assassinate needs the real stun status.
		local ReallyStunned = Stunned;

		-- Check if the enemy is in the spin state, let's assume that's a type of stun!
		if EntityState ~= nil and EntityState:GetState( "Spin" ) ~= nil then
			Stunned = true;
			Spinned = true;
		else
			Spinned = false;
		end
		
		
	----------------------------------------------
	-----------------Conditionals-----------------
	----------------------------------------------
	
	-- Retrieve the skill from the skill list.
	local Skill = SkillList:GetSkill( Entity_:GetSkillID());
			
	-- Check if this is a valid skill and is a magical skill, in which case we can use Aethertwisting.
	if Skill ~= nil and Skill:IsMagical() and Helper:CheckAvailable( "Aethertwisting" ) then
			Helper:CheckExecute( "Aethertwisting" );
	end
	if Skill ~= nil and Skill:IsMagical() and Helper:CheckAvailable( "Spelldodging" ) then
			Helper:CheckExecute( "Spelldodging" );
	end
	if Skill ~= nil and Helper:CheckAvailable( "Focused Evasion" ) then	
			Helper:CheckExecute( "Focused Evasion" );
	end
	-- 25m range activation
	if Range <= 25 then
	--Buff 1: Apply Deadly Poison
		if Player:GetState():GetState( Helper:CheckName( "Apply Deadly Poison" )) == nil and Helper:CheckAvailable( "Apply Deadly Poison" ) then
			Helper:CheckExecute( "Apply Deadly Poison" );	
		end
	end	
	-- 10m Range activation
	if Player:GetPosition():DistanceToPosition( Entity_:GetPosition()) <= 10 then
		if Helper:CheckAvailable( "Devotion" ) then
			Helper:CheckExecute( "Devotion" );
		elseif Helper:CheckAvailable( "Flurry" ) then
			Helper:CheckExecute( "Flurry" );
		end
	end
	-- Transformation: Slayer
	if Player:GetState():GetState( Helper:CheckName( "Transformation: Slayer" )) == nil and Helper:CheckAvailable( "Transformation: Slayer" ) then
					Helper:CheckExecute( "Transformation: Slayer" );
	end
	-- Transformation: Avatar of Fire
	if Player:GetState():GetState( Helper:CheckName( "Compassion of Fire" )) == nil and Helper:CheckAvailable( "Compassion of Fire" ) then
			Helper:CheckExecute( "Compassion of Fire" );
	end
	
	if Helper:CheckAvailable( "Sneak Ambush" ) then
		Helper:CheckExecute( "Sneak Ambush" );	
	end
	-- Start Chain 1: Killing Spree
	if Helper:CheckAvailable( "Killing Spree" ) then
		Helper:CheckExecute( "Killing Spree" );
	end
	-- Fang Strike -> Beast Swipe
	if Helper:CheckAvailable( "Beast Swipe" ) then
		Helper:CheckExecute( "Beast Swipe" );
	-- Beast Kick -> Beast Kick
	elseif Helper:CheckAvailable( "Beast Kick" ) then
		Helper:CheckExecute( "Beast Kick" );
	end
	
	-- Soul Slash  -> Rune Slash
	if Helper:CheckAvailable( "Soul Slash"  ) then
		Helper:CheckExecute( "Soul Slash" );
	elseif Helper:CheckAvailable( "Rune Slash" ) then
		Helper:CheckExecute( "Rune Slash" );	
	end
	-- Check how long since Entity has been Aetherheld, if above 3 seconds -> Use "Fall"
	if self._iBindingTime ~= nil and self._iBindingTime < Time() and Helper:CheckAvailable( "Fall" ) then
		Helper:CheckExecute( "Fall" );
		self._iBindingTime = nil;
	end
	
	if Range <= 2 and Helper:CheckAvailable ( "Back Breaker")  then
				
		if not Player:IsMoving() and not Player:IsBusy() then
			local PosE = Entity_:GetPosition();
			local dist = 1;  
			local Angle = Entity_:GetRotation();	
			PosE.X = PosE.X - dist*math.sin(Angle*(math.pi/180));
			PosE.Y = PosE.Y + dist*math.cos(Angle*(math.pi/180));
			Player:SetPosition(PosE);
			Helper:CheckExecute ("Back Breaker") ;
		end
	end
	-- Stunned -> Shadowfall
	if Helper:CheckAvailable( "Shadowfall" ) then
		Helper:CheckExecute( "Shadowfall" );
	end
	if Helper:CheckAvailable( "Evasive Boost" ) then
		Helper:CheckExecute( "Evasive Boost" );	
	end
	-- Evasion -> "Whirlwind Slash" or "Counter-Attack"
	if Helper:CheckAvailable("Whirlwind Slash") then
		Helper:CheckExecute("Whirlwind Slash");
	elseif Helper:CheckAvailable( "Cross Slash" ) then
		Helper:CheckExecute( "Cross Slash" );
	end
	
	-- Evasion -> "Whirlwind Slash" or "Counter-Attack"
	if Helper:CheckAvailable( "Cross Slash" ) then
		Helper:CheckExecute( "Cross Slash" );
	elseif Helper:CheckAvailable("Counter-Attack") then
		Helper:CheckExecute("Counter-Attack");	
	end

	if Helper:CheckAvailable( "Ambush Attack" ) then
		Helper:CheckExecute( "Ambush Attack" );
	elseif Helper:CheckAvailable(  "Ambush Assault"  ) then
		Helper:CheckExecute( "Ambush Assault" );
	end
	--------------------------------------------
	----------------Main Attacks----------------
	--------------------------------------------
	if Helper:CheckAvailable("Venomous Strike") then
		Helper:CheckExecute( "Venomous Strike" );
	end
	-- First Magical Attack
	if Helper:CheckAvailable( "Rune Carve" ) then
			Helper:CheckExecute( "Rune Carve");
	end
	-- Start Chain 2: Fang Strike
	if Helper:CheckAvailable( "Fang Strike" ) then
		Helper:CheckExecute( "Fang Strike" );
	
	end
	-- Start Chain 3: Swift Edge
	if Helper:CheckAvailable( "Swift Edge" ) then
		Helper:CheckExecute( "Swift Edge" );
	
	end
	-- Runes, Attack 4: Swift Edge
	if Helper:CheckAvailable( "Beast Fang" ) and Runes <= 3 then
		Helper:CheckExecute( "Beast Fang" );
	end
	-- Attack 4: Quickening Doom
	if Helper:CheckAvailable( "Quickening Doom" ) then
		Helper:CheckExecute( "Quickening Doom" );
	end
	if Helper:CheckAvailable( "Assassination" ) then
		Helper:CheckExecute( "Assassination" );		
	end
	--------------------------------------------
	-------------------Runes--------------------
	--------------------------------------------	
	if Runes >= 3 then
		if Helper:CheckAvailable( "Signet Silence" ) then
			Helper:CheckExecute( "Signet Silence" );
		end
	elseif Runes >= 3 then
		if Helper:CheckAvailable( "Binding Rune" ) then
			_iBindingTime = Time() + 1000;
			Helper:CheckExecute( "Binding Rune" );
		end
	elseif Runes >= 3 then
		if not Stunned and Helper:CheckAvailable( "Pain Rune Burst" ) then
			Helper:CheckExecute( "Pain Rune Burst" );
		end
	elseif Runes >= 2 then
		if Helper:CheckAvailable( "Repeated Rune Carve" ) then
			Helper:CheckExecute( "Repeated Rune Carve" );
		end

	end
	
	-- Attack 5: Surprise Attack (Spin)
	
	--if Player:GetPosition():DistanceToPosition(Entity_:GetPosition()) <= Player:GetAttackRange() then
	--		local PosE = Entity_:GetPosition();
	--		local dist = 1;  
	--		local Angle = Entity_:GetRotation();
	--		PosE.X = PosE.X - dist*math.sin(Angle*(math.pi/180));
	--		PosE.Y = PosE.Y + dist*math.cos(Angle*(math.pi/180));
	--	if not Player:IsBusy() and Helper:CheckAvailable("Bloodthirster Surprise Attack") then
	--		Player:SetPosition(PosE);
	--		Helper:CheckExecute( "Bloodthirster Surprise Attack" );
	--	end
	if Range <= 2 and Helper:CheckAvailable ( "Surprise Attack" ) then
			
		if not Player:IsMoving() and not Player:IsBusy() then
			local PosE = Entity_:GetPosition();
			local dist = 1;  
			local Angle = Entity_:GetRotation();	
			PosE.X = PosE.X - dist*math.sin(Angle*(math.pi/180));
			PosE.Y = PosE.Y + dist*math.cos(Angle*(math.pi/180));
			Player:SetPosition(PosE);
			Helper:CheckExecute( "Surprise Attack");
		end
	end
end

function Pause()

	
	return true;
	
end