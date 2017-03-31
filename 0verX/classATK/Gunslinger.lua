--[[

        --------------------------------------------------
        Copyright (C) 2013 VaanC + Macrokor

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
-- @param       Entity  Contains the entity we have targeted.
-- @param       double  Contains the distance to the target
-- @param       bool    Indicates whether or not the target is stunned.
-- @return      bool
function Attack( Entity, Range, Stunned )

	local Range = Player:GetPosition():DistanceToPosition( Entity:GetPosition());

	local Position = Player:GetPosition();

	local EntityState = Entity:GetState();

	local AttackRange = Player:GetAttackRange();

	local EntityState = Entity:GetState();

	----------------------------------------------
	---------Check For Enemy do somethink---------
	----------------------------------------------

	-- Quieting Gale (Normal stigma)
	if Helper:CheckAvailable( "Quieting Gale" ) and Entity:GetSkillID() ~= 0 and SkillList[Entity:GetSkillID()]:IsMagical() and Entity:GetSkillTime() >= 500 then
		Helper:CheckExecute( "Quieting Gale" );
		return false;
	end

	----------------------------------------------
	-----------------Remove Shock-----------------
	----------------------------------------------

	-- Remove Shock -> Steal Health
	if Helper:CheckAvailable( "Steal Health" ) and Player:GetHealth() < 70 then
		Helper:CheckExecute( "Steal Health" );
		return false;
	end

	-- Remove Shock
	if Helper:CheckAvailable( "Remove Shock" ) then
		Helper:CheckExecute( "Remove Shock" );
		return false;
	end

	----------------------------------------------
	---------------------Buffs--------------------
	----------------------------------------------

	-- Buff: Aion's Favor
	if Helper:CheckAvailable( "Aion's Favor" ) and EntityState:GetState( Helper:CheckName( "Aion's Favor" )) == nil then
		Helper:CheckExecute( "Aion's Favor" );
		return false;
	end


	----------------------------------------------
	---------------Recovery Skills----------------
	----------------------------------------------

	-- Anti-Enemy Fire
	if Helper:CheckAvailable( "Anti-Enemy Fire" ) and Player:GetHealth() < 70 then
		Helper:CheckExecute( "Anti-Enemy Fire" );
		return false;
	end

	-- Power Grab
	if Helper:CheckAvailable( "Power Grab" ) and Player:GetMana() < 80 then
		Helper:CheckExecute( "Power Grab" );
		return false;
	end

	----------------------------------------------
	-------------------Chain----------------------
	----------------------------------------------

	-- Volley -> Muzzle Flash
	if Helper:CheckAvailable( "Muzzle Flash" ) then
		Helper:CheckExecute( "Muzzle Flash" );
		return false;
	end

	-- Trunk Shot -> Volley
	if Helper:CheckAvailable( "Volley" ) then
		Helper:CheckExecute( "Volley" );
		return false;
	end

	-- Automatic Fire -> Steel Shot
	if Helper:CheckAvailable( "Steel Shot" ) then
		Helper:CheckExecute( "Steel Shot" );
		return false;
	end

	-- Rapidfire -> Automatic Fire
	if Helper:CheckAvailable( "Automatic Fire" ) then
		Helper:CheckExecute( "Automatic Fire" );
		return false;
	end

	-- Gunshot -> Rapidfire
	if Helper:CheckAvailable( "Rapidfire" ) then
		Helper:CheckExecute( "Rapidfire" );
		return false;
	end

	-- Canted Shot -> Aerial Shot
	if Helper:CheckAvailable( "Aerial Shot" ) then
		Helper:CheckExecute( "Aerial Shot" );
		return false;
	end

	-- Crosstrigger -> Trigger Pull or Canted Shot
	if Helper:CheckAvailable("Trigger Pull") then
		Helper:CheckExecute("Trigger Pull");
	elseif Helper:CheckAvailable( "Canted Shot" ) then
		Helper:CheckExecute( "Canted Shot" );
		return false;
	end

	--------------------------------------------
	----------------Main Attacks----------------
	--------------------------------------------

	--Initial Attack : Steady Fire
	if Helper:CheckAvailable( "Steady Fire" ) then
		Helper:CheckExecute( "Steady Fire" );
		return false;
	end

	--Initial Attack : Gunshot
	if Helper:CheckAvailable( "Gunshot" ) then
		Helper:CheckExecute( "Gunshot" );
		return false;
	end

	--Initial Attack : Packed Bomb
	if Position:DistanceToPosition( Entity:GetPosition()) >= 15 and Helper:CheckAvailable( "Packed Bomb" ) then
		Helper:CheckExecute( "Packed Bomb");
		return false;
	end

	--Initial Attack Immobilize : Green Grenade
	if Position:DistanceToPosition( Entity:GetPosition()) >= 15 and Helper:CheckAvailable( "Green Grenade" ) then
		Helper:CheckExecute( "Green Grenade");
		return false;
	end

	--Initial Attack : Trunk Shot
	if Helper:CheckAvailable( "Trunk Shot" ) then
		Helper:CheckExecute( "Trunk Shot" );
		return false;
	end

	--Initial Attack : Crosstrigger
	if Helper:CheckAvailable( "Crosstrigger" ) then
		Helper:CheckExecute( "Crosstrigger" );
		return false;
	end

	--Initial Attack : Precision Shot
	if Helper:CheckAvailable( "Precision Shot" ) then
		Helper:CheckExecute( "Precision Shot" );
		return false;
	end

	--Initial Attack : Hot Shot
	if Helper:CheckAvailable( "Hot Shot" ) then
		Helper:CheckExecute( "Hot Shot" );
		return false;
	end

	--Initial Attack : Spinning Fire
	if Helper:CheckAvailable( "Spinning Fire" ) then
		Helper:CheckExecute( "Spinning Fire" );
		return false;
	end

	-- Initial Attack : Automatic Attack
	if self.AttackStarted ~= Entity:GetID() then
		self.AttackStarted = Entity:GetID();
		Helper:CheckExecute( "Attack/Chat" );
		return false;
	end

end


--- Perform the required pause checks.
--
-- @return	bool

function Pause()

local PlayerState = Player:GetState();

	--Mana healing boost (Normal stigma)
	if Helper:CheckAvailable( "Nature's Favor" ) and PlayerState:GetState( Helper:CheckName( "Nature's Favor" )) == nil then
		Helper:CheckExecute( "Nature's Favor" );
		return false;
	end

	-- Nothing was executed, continue with other functions.
	return true;

end
