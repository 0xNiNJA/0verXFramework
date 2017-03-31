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
	if Player:GetTargetId() ~= 0 then
		Framework:OnRun();
	end
end


--- OnRun is called each frame to advance the script logic.
-- @return	void

function OnRun()
	
	if _AttackStarted ~= nil then
		
		local ShardAddress = DialogList:GetDialog( "basic_status_dialog/boost_marker" ):GetAddress();
		local Shard = Memory:GetUnsignedInteger(ShardAddress +424) > 1060000000;
		AggroEntity = Helper:FindTarget( true, Player:GetPosition());
		Entity = EntityList:GetEntity( Player:GetTargetId());
		
		
		--if Entity ~= nil and Entity:IsPlayer() and not Shard then
		
		--	if Helper:CheckAvailable( "Toggle Power Shard" ) then
		--		PlayerInput:Ability( "Toggle Power Shard" );
		--		return false;
		--	end	
		--end
	
		if Player:GetTargetID() == 0 then
			return false;
		
		elseif Player:IsDead() or Entity:IsDead() then 
			return false;
		end
		if Entity:IsDead() or Entity:IsGatherable() then
			
		
				return false;
		end
		if  Entity:IsPet() or Entity:IsFriendly() or Entity:IsObject() or Entity:IsKisk() then
			
			
			return false;
		end
		
		if Entity:IsHostile() or Entity:GetTargetID() == Player:GetID() then
			
			if not Player:IsMoving() and Helper:CheckAvailable( "Attack" ) and (Player:GetPosition():DistanceToPosition( Entity:GetPosition()) <= 35 and Player:GetPosition():DistanceToPosition( Entity:GetPosition()) >= 5) then
					PlayerInput:Ability( "Attack" );
			elseif Player:GetPosition():DistanceToPosition( Entity:GetPosition()) <= 5 then
				Range = Player:GetPosition():DistanceToPosition( Entity:GetPosition());
				return Controller:Attack( Entity, Player:GetPosition():DistanceToPosition( Entity:GetPosition()), Stunned, true );
			end
		end

	end
	end