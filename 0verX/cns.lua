--- OnLoad is called when the script is being initialized.
-- @return	void
function OnLoad()
	
	Settings = Include( "0verX/config.lua" );
	Helper = Include( "0verX/functions.lua" );
	
	if Settings == nil or Helper == nil or Settings.Initialize == nil then
		Write( "Unable to find/load the framework settings/helper functions!" );
		Close();
		return false;
	end

	Settings:Initialize();
	
	Controller = Include( "0verX/customATK/" .. Player:GetName() .. ".lua" );

	if Controller == nil then
		Controller = Include( "0verX/classATK/" .. Player:GetClass():ToString() .. ".lua" );
	else
		Class = Include( "0verX/classATK/" .. Player:GetClass():ToString() .. ".lua" );
	end

end


--- OnFrame: Detect movement stop on a per-frame basis to quickly chain movement.
-- @return	void
function OnFrame()
		--Framework:OnFrame();
	
		if Player:GetTargetId() ~= 0 then
			Entity = EntityList:GetEntity( Player:GetTargetID());
		Range = Player:GetPosition():DistanceToPosition( EntityList:GetEntity( Player:GetTargetID()):GetPosition());
			Framework:OnRun();
		end
end


--- OnRun is called each frame to advance the script logic.
-- @return	void

function OnRun()
	
	
	if _AttackStarted ~= nil then
		

		local ShardAddress = DialogList:GetDialog( "basic_status_dialog/boost_marker" ):GetAddress();
		local Shard = Memory:GetUnsignedInteger(ShardAddress +424) > 1060000000;
		
		if Player:IsDead() then
			return false;
		end
		if Player:GetTargetId() ~= 0 then
	
		Entity = EntityList:GetEntity( Player:GetTargetID());
		Range = Player:GetPosition():DistanceToPosition( EntityList:GetEntity( Player:GetTargetID()):GetPosition());
		local EntityAttitude =  Entity:GetAttitude():ToString();
		local EntityType = Entity:GetTypeID();		
		
			if Player:GetTargetId() == 0 or Entity:IsDead() then
				return false;
			end
			if Entity:GetTargetID() == Player:GetID() and not Entity:IsDead() and not Entity:IsObject() and not Entity:IsHidden() and Entity:IsHostile() then
				EntityIsAttackable = true;
			end
			if Entity:IsMonster() and EntityAttitude ~= "Friendly" and EntityAttitude ~= "Utility" and not Entity:IsPet() then
				EntityIsAttackable = true;
			end
			if Entity:IsPet() or Entity:IsFriendly() or Entity:IsObject() or Entity:IsKisk() then
				EntityIsAttackable = false;
				return false;
			end
		
			if EntityIsAttackable == true then
				if not Player:IsMoving() and not Player:IsBusy() and Helper:CheckAvailable( "Attack" ) and (Player:GetPosition():DistanceToPosition( Entity:GetPosition()) <= 35 and Player:GetPosition():DistanceToPosition( Entity:GetPosition()) >= 5) then
						PlayerInput:Ability( "Attack" );
						return true;
				else
					EntityIsAttackable = nil;
					return Controller:Attack( Entity, Player:GetPosition():DistanceToPosition( Entity:GetPosition()), Stunned, true );
				
				end
			end
		
		end

	end
end