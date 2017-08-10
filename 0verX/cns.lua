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
		OriginalAttackSpd =  Player:GetAttackSpeed();
		Player:SetAttackSpeed(299);
		
			OnRun();
		
		Player:SetAttackSpeed(OriginalAttackSpd);
end
		


--- OnRun is called each frame to advance the script logic.
-- @return	void

function OnRun()
	
	
	if _AttackStarted ~= nil then
		
		if Player:GetTargetId() ~= 0 and not Player:IsMoving() and not Player:IsBusy() then
			
			Entity = EntityList:GetEntity( Player:GetTargetID())
			
			
			if Entity == nil or Player:IsDead() or Entity:IsDead() then
				return false;
			
			else
				Range = Player:GetPosition():DistanceToPosition( Entity:GetPosition());	
				EntityAttitude =  Entity:GetAttitude():ToString();
				
			end
			
			Helper:IsAttackable()
		
			if Entity == nil or Player:IsDead() then
				EntityIsAttackable = false;
				return false;
			elseif Entity:IsDead() then
				EntityIsAttackable = false;
				return false;
			elseif Entity:IsGatherable() or Entity:IsPet() or Entity:IsFriendly() or Entity:IsDead() then
				
				return false;
			elseif Entity:IsHostile() or Entity:GetTargetID() == Player:GetID() then
			
			if  EntityIsAttackable ~= false and Range <= 35 and Range >= 5 then
						
			 return Helper:CheckExecute( "Attack" );
						 
						 
				elseif Range <= 35 then
						
					return Controller:Attack( Entity, Range, Stunned, true );
				end

				end
			end
			
		end
	
end
