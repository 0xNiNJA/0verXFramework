
function OnLoad()

	Helper = Include( "OfficialGrinderFramework/HelperFunction.lua" );
	Settings = Include( "OfficialGrinderFramework/Settings.lua" );

	if Player:GetClass():ToString() == "Cleric" then
		Write( "Thanks for using my script!  Please direct any bug" );
		Write( "reports or suggestions to my thread at:" );
		Write( " http://www.aionscript.com/index.php/topic,1011.0.html" );
	else
		Write( "You are not a cleric!" );
		Close();

	end

	Settings:Initialize();

	PreviousPosition = Player:GetPosition();

end

function OnRun()

	if not Settings.AllowInsaneCpuConsumption or Player:GetTargetId() == 0 then
		Main();
	end
end

function OnFrame()

	if Settings.AllowInsaneCpuConsumption and Player:GetTargetId() ~= 0 then
		Main();
	end
end

--- Contains the main script routine.
--
-- @return void

function Main()

	-- Check if we're is moving so we can avoid skills that will stop us.
	local InMotion = CheckMovement();

	-- Initialize the variable that we need to keep the currently targeted entity.
	local Entity = EntityList:GetEntity( Player:GetTargetID());

        -- Check if the player is currently busy or dead.
        if Player:IsBusy() or Player:IsDead() then
                return false;
        end

        -- Check if the player has a silence state and attempt to remove it.
        if not CheckSilence() then
                return false;
        end

        -- Check if the player has been shocked and attempt to remove it.
        if not CheckShock() then
                return false;
        end
        
        -- Check if the player has a negative state and remove it.
        if not CheckState( Player ) then
                return false;
        end

	-- Check if we are not currently resting and use potions if necessary.
	if not Player:IsResting() then

		-- Check if a health potion is allowed and check if we have reached the threshold.
		if Settings.PotionHealth > 0 and Player:GetHealth() <= Settings.PotionHealth and not Helper:CheckPotionHealth() then
			return false;
		end

		-- Check if a mana potion is allowed and check if we have reached the threshold.
		if Settings.PotionMana > 0 and Player:GetMana() <= Settings.PotionMana and not Helper:CheckPotionMana() then
			return false;
		end

		-- Check if a recovery potion is allowed and check if we have reached the threshold.
		if Settings.PotionRecovery > 0 and Player:GetHealth() <= Settings.PotionRecovery and Player:GetMana() <= Settings.PotionRecovery and not Helper:CheckPotionRecovery() then
			return false;
		end

	end

	-- Check if the Player is injured and attempt to heal.
	if not CheckHeal( Player ) then
		return false;
	end


        -- Check the states of the force members (Dispel/Cure Mind).
        for ID, Force in DictionaryIterator( ForceList:GetList()) do
                
                -- Retrieve the entity for the current force member.
                local Entity = EntityList:GetEntity( Force:GetID());
                
                -- Check if the current force members has state modifications that need to be removed.
                if Entity ~= nil and not CheckState( Entity ) then
                        return false;
                end

        end

	-- Check if any buffs have expired and reapply if necessary.
	if not CheckBuff() then
		return false;
	end

	--If the target is valid and not us, start attacking.
	if not (Player:GetTargetID() == 0 or Player:GetTargetID() == Player:GetID()) then

		-- Check if the current target is set correctly to the intended target.
		if Player:GetTargetID() ~= Entity:GetID() then
			Player:SetTarget( Entity );
		end

		-- Check if the target is dead and do nothing if it is.
		if Entity:IsDead() then
			return true;
		end

		-- Check if we are currently in the resting state and stand up when we are.
		if Player:IsResting() then
			PlayerInput:Ability( "Toggle Rest" );
			return false;
		end	

		-- Check if the target does not have a target.
		--if Entity:GetTargetId() == 0 and Player:GetClass():ToString() ~= "Spiritmaster" then
		--	-- Retrieve the distance to the target.
		--	local LosPosition = Player:GetPosition();
		--	-- Initialize a boolean indicating whether the Los is valid.
		--	local LosValid = false;
		--	-- Check if this entity matches the Los-variables.
		--	if self._LosPosition ~= nil and self._LosId ~= nil and self._LosTime ~= nil and Entity:GetId() == self._LosId then
		--		-- Check if the distance has changed.
		--		if self._LosPosition.X ~= LosPosition.X or self._LosPosition.Y ~= LosPosition.Y or self._LosPosition.Z ~= LosPosition.Z then
		--			LosValid = true;
		--		-- Check if we are performing an attack.
		--		elseif Player:GetSkillId() ~= 0 then
		--			LosValid = true;
		--		end
		--	-- Otherwise set the Los-variables.
		--	else
		--		LosValid = true;
		--		self._LosPosition = LosPosition;
		--		self._LosId = Entity:GetId();
		--		self._LosTime = Time();
		--	end
		--	-- Check if the Los is not valid.
		--	if not LosValid then
		--		-- Check if the time has expired for the Los check!
		--		if self._LosTime + 2500 < Time() then
		--			self._LosIdSkip = Entity:GetId();
		--			Player:SetTarget( Player );
		--		end
		--	-- Otherwise extend the Los time.
		--	else
		--		self._LosTime = Time();
		--	end					
		--else
		--	self._LosIdSkip = nil;
		--end

		Attack( Entity, Entity:GetPosition():DistanceToPosition( Player:GetPosition()), Stunned, InMotion );

	end

end

--- Perform the attack routine on the selected target.
--
-- @param	Entity	Contains the entity we have targeted.
-- @param	double	Contains the distance to the target
-- @param	bool	Indicates whether or not the target is stunned.
-- @param	bool	Indicates whether or not to use skills with cast times.
-- @return	bool

function Attack( Entity, Range, Stunned, InMotion )

	-- Indicates whether or not attacks are allowed for a Cleric. Extra toggle to allow features such as follow-mode support.
	--if Settings.Cleric.AllowAttack then

		-- Check if the target is not attacking us and attack only with a servant.
		--if Settings.Cleric.AllowAttackDelay and ( self._DelayEntityId == nil or self._DelayEntityId ~= Entity:GetID()) and not Helper:CheckAvailable( "Summon Holy Servant" ) then
		--	return true;
		--end

		if Helper:CheckAvailable( "Storm of Vengeange" ) then
			Helper:CheckExecute( "Storm of Vengeance" );
			return false;
		end

		-- Chain 1: Punishing Earth/Smite
		if Helper:CheckAvailable( "Thunderbolt" ) then
			Helper:CheckExecute( "Thunderbolt" );
			return false;
		elseif Helper:CheckAvailable( "Divine Spark" ) then
			Helper:CheckExecute( "Divine Spark" );
			return false;
		end
		
		-- Chain 2: Punishing Wind/Hallowed Strike
		if Helper:CheckAvailable( "Infernal Blaze" ) then
			Helper:CheckExecute( "Infernal Blaze" );
			return false;
		elseif Helper:CheckAvailable( "Divine Touch" ) then
			Helper:CheckExecute( "Divine Touch" );
			return false;
		end
		
		-- Attack 1: Summon Noble Energy
		if Helper:CheckAvailable( "Summon Noble Energy" ) then
			Helper:CheckExecute( "Summon Noble Energy" );
			return false;
		end
		
		-- Attack 2: Summon Holy Servant
		if Helper:CheckAvailable( "Summon Holy Servant" ) then
			Helper:CheckExecute( "Summon Holy Servant" );
			return false;
		end
		
		-- Heal 1: Summon Healing Servant
		if Settings.Cleric.AllowHealing and Helper:CheckAvailable( "Summon Healing Servant" ) then
			Helper:CheckExecute( "Summon Healing Servant" );
			return false;
		end
		
		-- Chain 1: Punishing Earth
		if Helper:CheckAvailable( "Punishing Earth" ) then
			Helper:CheckExecute( "Punishing Earth" );
			return false;
		-- Chain 1: Smite (Thunderbolt related!)
		elseif Helper:CheckAvailable( "Thunderbolt" ) and Helper:CheckAvailable( "Smite" ) then
			Helper:CheckExecute( "Smite" );
			return false;
		end

		-- Attack 4: Chastise
		if Helper:CheckAvailable( "Chastise" ) then
			Helper:CheckExecute( "Chastise" );
			return false;
		end

		-- Chain 2: Punishing Wind
		if Helper:CheckAvailable( "Punishing Wind" ) then
			Helper:CheckExecute( "Punishing Wind" );
			return false;
		elseif Helper:CheckAvailable( "Slashing Wind" ) then
			Helper:CheckExecute( "Slashing Wind" );
			return false;
		end
		
		-- Check if high mana consumption skills are allowed.
		if Settings.Cleric.AllowAttackMana then
			-- Attack 5: Call Lightning
			if Helper:CheckAvailable( "Call Lightning" ) and not InMotion then
				Helper:CheckExecute( "Call Lightning" );
				return false;
			end
			
			-- Attack 6: Enfeebling Burst
			if Helper:CheckAvailable( "Enfeebling Burst" ) then
				Helper:CheckExecute( "Enfeebling Burst" );
				return false;
			end
		end

		if Helper:CheckAvailable( "Chain of Suffering" ) and Entity:GetHealth() < 40 and not InMotion then
			Helper:CheckExecute( "Chain of Suffering" );
			return false;
		end

		-- Attack 3: Earth's Wrath
		if Helper:CheckAvailable( "Earth's Wrath" ) and not InMotion then
			Helper:CheckExecute( "Earth's Wrath" );
			return false;
		end
		
		-- Attack 5: Storm of Aion
		if Helper:CheckAvailable( "Storm of Aion" ) then
			Helper:CheckExecute( "Storm of Aion" );
			return false;
		end
		
		-- Chain 2: Hallowed Strike (Lower Form)
		if Helper:CheckAvailable( "Hallowed Strike" ) and (Settings.Cleric.AllowApproach or Range < 4) then
			Helper:CheckExecute( "Hallowed Strike" );
			return false;
		end
		
		-- Chain 1: Smite (Lower Form)
		if Helper:CheckAvailable( "Smite" ) and not InMotion then
			Helper:CheckExecute( "Smite" );
			return false;
		end

	--end
	
	-- Nothing was executed, continue with other functions.
	return true;

end


--- Checks the healing requirements for the provided entity.
--
-- @param	Entity	Contains the entity to perform healing on.
-- @return	bool

function CheckHeal( Entity )

	-- Retrieve the range of the entity compared to my own character position.
	local Range = Player:GetPosition():DistanceToPosition( Entity:GetPosition());
	
	-- Check if this routine is allowed to be ran under the current circumstances.
	if Entity:IsDead() or ( not Settings.Cleric.AllowApproach and Range > 23 ) then
		return true;
	end

	-- Check if the entity requires healing and perform the correct healing routine.
	if Entity:GetHealth() < 80 and ( Settings.Cleric.AllowApproach or Range <= 23 ) then
	
		-- Retrieve the local target for certain checks.
		local Target = EntityList:GetEntity( Player:GetTargetID());
		
		-- Change the healing routine if I'm healing myself.
		if Entity:GetID() == Player:GetID() then -- and Target ~= nil and not Target:IsDead() then
			if Entity:GetHealth() < 10 and Entity:GetMana() > 40 and Helper:CheckAvailable( "Reverse Condition" ) and not Helper:CheckAvailable( "Flash of Recovery" ) then
				Helper:CheckExecute( "Reverse Condition" );
				return false;
			elseif Entity:GetHealth() < 25 and Helper:CheckAvailable( "Flash of Recovery" ) then
				if Helper:CheckAvailable( "Blessed Shield" ) then
					Helper:CheckExecute( "Blessed Shield" );
					return false;
				end
				Helper:CheckExecute( "Flash of Recovery", Entity );
				return false;
			elseif Entity:GetHealth() < 35 and Helper:CheckAvailable( "Light of Recovery" ) then
				Helper:CheckExecute( "Light of Recovery", Entity );
				return false;
			elseif Entity:GetHealth() < 50 and Helper:CheckAvailable( "Healing Light" ) then
				Helper:CheckExecute( "Healing Light", Entity );
				return false;
			end
		-- Check if we should flash the provided entity.
		elseif Entity:GetHealth() < 50 and Helper:CheckAvailable( "Flash of Recovery" ) then
			Helper:CheckExecute( "Flash of Recovery", Entity );
			return false;
		-- Check if we should heal the provided entity more quickly.
		elseif Entity:GetHealth() < 70 and Helper:CheckAvailable( "Light of Recovery" ) then
			Helper:CheckExecute( "Light of Recovery", Entity );
			return false;
		-- Check if we should heal the provided entity.
		elseif Helper:CheckAvailable( "Healing Light" ) then
			Helper:CheckExecute( "Healing Light", Entity );
			return false;
		end
		
	end
	
	-- Return true to let the caller know this function completed.
	return true;
	
end

--- Check if the player is missing any buffs and apply as necessary.
--
-- @return	bool

function CheckBuff()

	-- Check if we have a pending Light of Rejuvenation, which happens directly after Penance.
	--local Ability = AbilityList:GetAbility( "Penance" );
	--if Helper:CheckAvailable( "Light of Rejuvenation" ) and Ability:GetCooldown() > 175 and not Helper:CheckAvailable( "Penance" ) then
	--	Helper:CheckExecute( "Light of Rejuvenation" );
	--	return false;
	--end

	-- Check if we have enough capacity to contain mana to enable penance.
	if ( Player:GetManaMaximum() - Player:GetManaCurrent()) >= 2150 and Helper:CheckAvailable( "Penance" ) and Helper:CheckAvailable( "Light of Rejuvenation" ) then
		Helper:CheckExecute( "Penance" );
		return false;
	end

	local EntityState = Player:GetState();

	if EntityState ~= nil then

		-- Check if this entity has the Blessing of Health state.
		if Helper:CheckAvailable( "Blessing of Health I" ) and EntityState:GetState( "Blessing of Health I" ) == nil and EntityState:GetState( "Blessing of Health II" ) == nil then
			Helper:CheckExecute( "Blessing of Health", Player );
			return false;
		end
		
		-- Check if this entity has the Blessing of Rock state.
		if Helper:CheckAvailable( "Blessing of Rock I" ) and EntityState:GetState( "Blessing of Rock I" ) == nil and EntityState:GetState( "Blessing of Stone I" ) == nil then
			Helper:CheckExecute( "Blessing of Rock", Player );
			return false;
		end
		
		-- Check if this entity has the Promise of Wind state.
		if Helper:CheckAvailable( "Promise of Wind" ) and EntityState:GetState( Helper:CheckName( "Promise of Wind" )) == nil then
			Helper:CheckExecute( "Promise of Wind", Player );
			return false;
		end
		
		-- Check if AllowSummerCircleBuff is set and if entity needs Summer Circle State
		if Settings.Cleric.AllowSummerCircleBuff and Helper:CheckAvailable( "Summer Circle" ) and EntityState:GetState( Helper:CheckName( "Summer Circle" )) == nil then
			Helper:CheckExecute( "Summer Circle", Player );
			return false;
		end
		
		-- Check if AllowWinterCircleBuff is set and if entity needs Winter Circle State
		if not Settings.Cleric.AllowSummerCircleBuff and Settings.Cleric.AllowWinterCircleBuff and Helper:CheckAvailable( "Winter Circle" ) and EntityState:GetState( Helper:CheckName( "Winter Circle" )) == nil then
			Helper:CheckExecute( "Winter Circle", Player );
			return false;
		end
		
		-- Check if AllowRebirth and if this entity has the Rebirth state.
		if Settings.Cleric.AllowRebirth and Helper:CheckAvailable( "Rebirth I" ) and EntityState:GetState( "Rebirth I" ) == nil then
			Helper:CheckExecute( "Rebirth I", Player );
			return false;
		end
		
	end

	-- Nothing was executed, continue with other functions.
	return true;

end

--- Check if the player has been shocked and attempt to remove it.
--
-- @return      bool

function CheckShock()

        -- Retrieve the remove shock ability.
        local Ability = AbilityList:GetAbility( "Remove Shock I" );
        
        -- Check if the ability exists, has been activated and can be used.
        if Ability ~= nil and Ability:GetActivated() and Ability:GetCooldown() == 0 then
                PlayerInput:Ability( Ability:GetName());
                return false;
        end
        
        -- Return true to let the caller know this method completed.
        return true;
        
end

        
--- Check if the player has a silence state and attempt to remove it.
--
-- @return      bool

function CheckSilence()

        -- Initialize the negative state number.
        local NegativeNumber = 0;
        
        -- Retrieve the player state.
        local PlayerState = Player:GetState();
        
        -- Retrieve the lesser potion item.
        local PotionLesser = InventoryList:GetInventory( "Lesser Healing Potion" );
        
        -- Retrieve the greater potion item.
        local PotionGreater = InventoryList:GetInventory( "Greater Healing Potion" );

        -- Check if the retrieved player state is correct.
        if PlayerState == nil then
                return false;
        end
                        
        -- Loop through all of the available player states.
        for ID, Skill in DictionaryIterator( PlayerState:GetList()) do
                
                -- Check if this state has a negative effect.
                if Skill:IsDebuff() then
                
                        -- Increment the negative state number.
                        NegativeNumber = NegativeNumber + 1;
                        
                        -- Check if the current state has a silence effect.
                        if  StartsWith( Skill:GetName(), "Silence Arrow" )
                                or StartsWith( Skill:GetName(), "Signet Silence" )
                                or StartsWith( Skill:GetName(), "Soul Freeze" )
                                or StartsWith( Skill:GetName(), "Sigil of Silence" )
                                or Skill:GetName() == "Godstone: Jumentis’s Pacification"
                                or Skill:GetName() == "Godstone: Sigyn’s Tranquility"
                                or Skill:GetName() == "Godstone: Khrudgelmir’s Tacitness"
                                or Skill:GetName() == "Godstone: Khrudgelmir’s Silence"
                                or Skill:GetName() == "Godstone: Beritra’s Plot" then

                                -- Check if this silence effect is at the first position and we can use a small potion.
                                if NegativeNumber == 1 and PotionLesser ~= nil and PotionLesser:GetCooldown() == 0 then
                                        PlayerInput:Inventory( PotionLesser:GetName());
                                        return false;
                                -- Check if this silence effect is at the first position and we can use a large potion.
                                elseif NegativeNumber == 1 and PotionGreater ~= nil and PotionGreater:GetCooldown() == 0 then
                                        PlayerInput:Inventory( PotionGreater:GetName());
                                        return false;
                                -- Check if this silence effect is at the second position and we can use a large potion.
                                elseif NegativeNumber == 2 and PotionGreater ~= nil and PotionGreater:GetCooldown() == 0 then
                                        PlayerInput:Inventory( PotionGreater:GetName());
                                        return false;
                                -- Otherwise we cannot remove the silence effect.
                                else
                                        return false;
                                end                                     
                                        
                        end
                                
                end
                        
        end
                
        -- Return true to let the caller know this method completed.
        return true;

end


--- Checks if the state of the provided entity.
--
-- @param       Entity Contains the entity to check.
-- @return      bool

function CheckState( Entity )

        -- Check if the current entity is valid, is alive and is in range.
        if Entity == nil or Entity:IsDead() or Player:GetPosition():DistanceToPosition( Entity:GetPosition()) > 23 then
                return true;
        end

        -- Retrieve the entity state.
        local EntityState = Entity:GetState();
        
        -- Check if the retrieved entity state is correct.
        if EntityState ~= nil then
                
                -- Loop through all of the available player states.
                for ID, Skill in DictionaryIterator( EntityState:GetList()) do
                                
                        -- Check if this state has a negative effect.
                        if Skill:IsDebuff() then
                                        
                                -- Check if this state can be dispelled using Cure Mind.
                                if Skill:GetDispell():ToString() == "Mental" then
                                        return Helper:CheckExecute( "Cure Mind", Entity );
                                -- Check if this state can be dispelled using Dispel.
                                elseif Skill:GetDispell():ToString() == "Physical" then
                                        return Helper:CheckExecute( "Dispel", Entity );
                                end
                        
                        end
                        
                end
                
        end
        
        -- Return true to let the caller know this method completed.
        return true;
        
end

--- Monitors Player's coordinates for movement and sets a flag for skills with cast times.
--
-- @return	bool

function CheckMovement()

	-- Get our current coordinates.
	local CurrentPosition = Player:GetPosition();

	-- Compare new coordinates to old.
	if CurrentPosition.X ~= PreviousPosition.X or CurrentPosition.Y ~= PreviousPosition.Y or CurrentPosition.Z ~= PreviousPosition.Z then
		PreviousPosition = CurrentPosition;
		--Write( "Moving" );
		return true;
	else
		--Write( "Stopped" );
		return false;
	end

end


--- Determines whether the beginning of this string instance matches a specified string.
--
-- @param       string The string to compare.
-- @param       string The string to match.
-- @return      bool

function StartsWith( String, Start )
   return string.sub( String, 1, string.len( String )) == Start;
end