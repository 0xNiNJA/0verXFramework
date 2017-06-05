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
		
	

			OnRun();
		end
		


--- OnRun is called each frame to advance the script logic.
-- @return	void

function OnRun()
	
	if _AttackStarted ~= nil then
	
		if Player:GetTargetId() ~= 0 and not Player:IsMoving() and not Player:IsBusy() then
		
			if Player:IsDead() or Player:GetTargetId() == 0 then
				return false;
			end
			
			
			Range = Player:GetPosition():DistanceToPosition( Entity:GetPosition());	
			EntityAttitude =  Entity:GetAttitude():ToString();
			if Entity:GetTargetID() == Player:GetID() and not Entity:IsDead() and not Entity:IsObject() and not Entity:IsHidden() and Entity:IsHostile() and Entity:IsMonster() and not Entity:IsPet() then
				EntityIsAttackable = true;
			end
			if EntityAttitude ~= "Friendly" then
				EntityIsAttackable = true;
			end
			if Entity:IsPet() or Entity:IsFriendly() or Entity:IsObject() or Entity:IsKisk() or EntityAttitude == "Utility" or  Entity:IsDead() then
				EntityIsAttackable = false;
				return false;
			end
		
			if EntityIsAttackable == true then
			
				if  Helper:CheckAvailable( "Attack" ) and Range <= 35 and Range >= 5 then
						
						 return Helper:CheckExecute( "Attack" );
						 
						 
				elseif Range <= 35 then
						
					return Controller:Attack( Entity, Range, Stunned, true );
				end
			EntityIsAttackable = nil;
				end
			end
			
		end
	
end
