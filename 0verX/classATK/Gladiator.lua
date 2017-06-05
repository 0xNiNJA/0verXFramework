--[[

	--------------------------------------------------
	Copyright (C) 2011 kintarooe & rellis

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
-- @param	Entity	Contains the entity we have targeted.
-- @param	double	Contains the distance to the target
-- @param	bool	Indicates whether or not the target is stunned.
-- @return	bool

function Attack( Entity, Range, Stunned )

	-- Target Casting use Lockdown
	if Entity:GetSkillID() > 0 and Entity:GetSkillTime() > 1 and Helper:CheckAvailable( "Lockdown" ) then
		--Write ( "Target using skill ID " .. Entity:GetSkillID() .. " with cast time of " .. Entity:GetSkillTime() .. " using Lockdown." );
		Helper:CheckExecute( "Lockdown" );
		return false;
	end
	


	-- Chain 1: Remove Shock (Care on WE aoe attack)
	if not Stunned and Helper:CheckAvailable( "Ferocity" ) then
		Helper:CheckExecute( "Ferocity" );
		return false;
	elseif Helper:CheckAvailable( "Wrathful Explosion" ) then 
		Helper:CheckExecute( "Wrathful Explosion" );
		return false;
	elseif Helper:CheckAvailable( "Remove Shock" ) then
		Helper:CheckExecute( "Remove Shock" );
		return false;
	end

	-- Buffs
	if Entity:GetHealth() >= 50 and Helper:CheckAvailable( "Shadow Rage" ) then
		Helper:CheckExecute( "Shadow Rage");
		return false;
    end
	
	--if Entity:GetHealth() < 90 and Helper:CheckAvailable( "Unwavering Devotion" ) then
	--	Helper:CheckExecute( "Unwavering Devotion" );
	--	return false;
	--end
	
	if Entity:GetHealth() >= 50 and Player:GetHealth() <= 60 and Helper:CheckAvailable( "Wall of Steel" ) then
		Helper:CheckExecute( "Wall of Steel" );
		return false;
	end
	

	
-- BEGIN STATE ACTIVATED SKILLS
if Entity:GetHealth() >= 50 and Helper:CheckAvailable( "Daevic Fury" ) and Player:GetDP() >=2000 then
 Helper:CheckExecute( "Daevic Fury");
return false;
elseif Helper:CheckAvailable( "Zikel's Threat" ) and Player:GetDP() >=4000 then
  Helper:CheckExecute( "Zikel's Threat");
return false;
end

	-- Successful Parry
	if Helper:CheckAvailable( "Counter Leech" )  and Range <= 3 then
		Helper:CheckExecute( "Counter Leech" );
		return false;
	end
	
	if Helper:CheckAvailable( "Sure Strike" ) and Range <= 3 then
		Helper:CheckExecute( "Sure Strike" );
		return false;
	end
	if Helper:CheckAvailable( "Piercing Rupture" ) and Range <= 9 then
			Helper:CheckExecute( "Piercing Rupture" );
			return false;
		end
	if Helper:CheckAvailable( "Draining Sword" ) and Player:GetHealthCurrent() < Player:GetHealthMaximum() - 2550 and Range <= 3 then
		Helper:CheckExecute( "Draining Sword" );
		return false;
	end
	-- Mob Stumbled Skills
	-- Check if Health status warrants using Draining Blow
	if Helper:CheckAvailable( "Draining Blow VIII" ) and Range <= 6  then
		Helper:CheckExecute( "Draining Blow VIII" );
		return false;
	elseif Helper:CheckAvailable( "Crippling Cut" ) and Range <= 6  then
		Helper:CheckExecute( "Crippling Cut" );
		return false;
	elseif Helper:CheckAvailable( "Springing Slice" ) and Range  > 15  then
		Helper:CheckExecute( "Springing Slice" );
		return false;
	end
	if Helper:CheckAvailable( "Final Strike" )  and Range <= 6  then
		return false;
	end
	
	-- Mob Aether's Hold
	if Helper:CheckAvailable( "Final Strike" ) then
		Helper:CheckExecute( "Final Strike" );
		return false;
	elseif Helper:CheckAvailable( "Crashing Blow" ) then
		Helper:CheckExecute( "Crashing Blow" );
		return false;
	end
	
-- END STATE ACTIVATED SKILLS

-- BEGIN CHAIN ACTIVATED SKILLS	
	
	-- Chain 2: Rupture
	if Helper:CheckAvailable( "Reckless Strike" ) then
		Helper:CheckExecute( "Reckless Strike" );
		return false;
	end

	
	-- Chain 6: AoE Chain - Seismic Wave/Absorbing Fury
	if Helper:CheckAvailable( "Exhausting Wave" ) and Range <= 6 then
		Helper:CheckExecute( "Exhausting Wave" );
		return false;
		end
	-- Chain 6: AoE Chain - Seismic Wave/Absorbing Fury
	if Helper:CheckAvailable( "Earthquake Wave" ) and Range <= 6 then
		Helper:CheckExecute( "Earthquake Wave" );
		return false;
		end
	if Helper:CheckAvailable( "Fury Absorption" ) and Range <= 6 then
			Helper:CheckExecute( "Fury Absorption" );
			return false;
		end
	-- Chain 2: Ferocious Strike
	if Helper:CheckAvailable( "Robust Blow" ) then
		Helper:CheckExecute( "Robust Blow" );
		return false;
	--elseif Helper:CheckAvailable( "Rage" ) then
	--	Helper:CheckExecute( "Rage" );
	--	return false;
	end

	-- Chain 2: Robust Blow
	if Helper:CheckAvailable( "Wrathful Strike" ) then
		Helper:CheckExecute( "Wrathful Strike" );
		return false;
	elseif Helper:CheckAvailable( "Rupture" ) then
		Helper:CheckExecute( "Rupture" );
		return false;
	end

-- END CHAIN ACTIVATED SKILLS

-- BEGIN RANGED SKILLS

	-- Ranged skills
	if Range <= 20 then
	
		-- Ranged Stumbled 1: Springing Slice
		if Helper:CheckAvailable( "Springing Slice" ) then
			Helper:CheckExecute( "Springing Slice" );
			return false;
		end
	
		-- Ranged Chain 2: Great Cleave
		if Helper:CheckAvailable( "Righteous Cleave" ) then
			Helper:CheckExecute( "Righteous Cleave" );
			return false;
		end
		
		-- Ranged Chain 1: Cleave
		if Helper:CheckAvailable( "Great Cleave" ) then
			Helper:CheckExecute( "Great Cleave" );
			return false;
		elseif Helper:CheckAvailable( "Force Cleave" ) then
			Helper:CheckExecute( "Force Cleave" );
			return false;
		end
		
		-- Ranged Attack 1: Cleave
		if Helper:CheckAvailable( "Cleave" ) then
			Helper:CheckExecute( "Cleave" );
			return false;
		end
		
	end
	
-- BEGIN PRIMARY ATTACK SKILLS

	
	-- Severe Weakening Blow
	if Helper:CheckAvailable( "Weakening Blow" ) then
		Helper:CheckExecute( "Weakening Blow" );
		return false;
	end
	
	-- Attack 3: Ferocious Strike
	if Helper:CheckAvailable( "Ferocious Strike" ) then
		Helper:CheckExecute( "Ferocious Strike" );
		return false;
	end
	-- Attack 3: Ferocious Strike
	if Helper:CheckAvailable( "Body Smash" ) then
		Helper:CheckExecute( "Body Smash" );
		return false;
	end
	-- Attack 3: Ferocious Strike
	if Helper:CheckAvailable( "Sharp Strike" ) then
		Helper:CheckExecute( "Sharp Strike" );
		return false;
	end
	-- Attack 4: Aerial Lockdown
	if Helper:CheckAvailable( "Aerial Lockdown" ) then
		Helper:CheckExecute( "Aerial Lockdown" );
		return false;
	end
	
	-- Attack 5: AoE Skills
	if Settings.Gladiator.AllowAoe and Range <= 6 then
		--if Helper:CheckAvailable( "Fury Absorption" ) then
		--	Helper:CheckExecute( "Fury Absorption" );
		--	return false;
		--end
		
	end
	
	-- Chain 2 Attack: Ferocious Strike
	if self.FerociousTrigger ~= nil and Helper:CheckAvailable( "Ferocious Strike" ) then
		if Helper:CheckExecute( "Ferocious Strike" ) then
			self.FerociousTrigger = nil;
			return false;
		end
	end

-- END PRIMARY ATTACK SKILLS
	
end

--- Perform healing checks both in and our of combat.
--
-- @param	bool	Indicates whether or not the function is running before force checks.
-- @return	bool

function Heal( BeforeForce )
		

-- Check if we should recharge our health using recovery spell.
	if Helper:CheckAvailable( "Second Wind" ) and Player:GetHealth() < 50 then
		Helper:CheckExecute( "Second Wind");
		return false;
	end

	-- Nothing was executed, continue with other functions.
	return true;
	
end

--- Perform the safety checks before moving to the next target.
--
-- @return	bool

function Pause()

	-- Nothing was executed, continue with other functions.
	return true;
	
end