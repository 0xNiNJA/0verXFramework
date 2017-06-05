-------------------------------------------------------------
--	0xPvP_E 2.1				   --
-------------------------------------------------------------
--							   --
--	This script uses 0verX framework - 
--  it is a tweaked version of OfficialGrinderFramework	   --
--	so keep in mind the settings you have there.	 	   --
--							  							   --
--														   --
--		AionScript (c) 2011, Script By JotaC	 		   --
--		0verkill LUA Script (c) 2015, Script By 0x00.NiNJA --
--							   --
-------------------------------------------------------------

function OnLoad()
	-- Settings
	-- Check the key codes here (Member Name): http://msdn.microsoft.com/en-us/library/system.windows.input.key.aspx
	Register( "AttackHandle", "Oem8" );
	Register( "SetHideDetection", "Insert" );
	Register( "BuffHandle", "Home" );
	Register( "AttackSPDCheckEntity", "End" );
	-- End Settings
	
	Settings = Include( "0verX/config.lua" );
	Helper = Include( "0verX/functions.lua" );
	Framework = Include( "0verX/cns.lua" );
	Framework:OnLoad();	
	
	Write("The 0xPvP_e Script 2.1");	
	Write("Don't forget to edit CustomCFG/Example.lua");	
	Write("and rename Example.lua to your char!");	
	Write(" DELETE - Auto-Roll / Loot");	
	Write("¬ (OEM Key) - AutoAttack / AutoReact");
	Write("Insert - Enhance Vision - view hidden chars!");
end
function OnFrame()

	if not Player:IsMoving() and not Player:IsBusy() then
		Framework:OnRun();
	end
		
end

function OnRun()
		
		if Player:GetTargetId() ~= 0 then
			
			Entity = EntityList:GetEntity( Player:GetTargetID());
			Framework:OnRun();
		end
		

end

function AttackHandle()
	
	if _AttackStarted ~= nil then
			_AttackStarted = nil;
			Player:SetHideDetectionLevel(0)
			--DialogList:GetDialog( "radar_dialog" ):SetVisible( true );
			--DialogList:GetDialog( "chat_dialog" ):SetVisible( true );
			DialogList:GetDialog( "subzone_name_dialog" ):SetVisible( true );
			Write("0verkill Mode: DISABLED!");	
			PlayerInput:Console("/w " .. PlayerWhisperName .. " 0verkill mode DISABLED!");
		else
			_AttackStarted = true;
			Player:SetHideDetectionLevel(2);
			--DialogList:GetDialog( "radar_dialog" ):SetVisible( false );
			--DialogList:GetDialog( "chat_dialog" ):SetVisible( false );
			DialogList:GetDialog( "subzone_name_dialog" ):SetVisible( false );
			Write("0verkill Mode: ENABLED!");
			PlayerInput:Console("/w " .. PlayerWhisperName .. " 0verkill mode ENABLED!");
			
	end
end

function SetHideDetection()
	if _SetHideStarted ~= nil then
		Write("ENHANCHED VISION : disabled!");
		Player:SetHideDetectionLevel(0);
		_SetHideStarted = nil;
	else
		Write("ENHANCHED VISION : ENABLED!");
		Player:SetHideDetectionLevel(2);
		_SetHideStarted = true;
	end
end
function UIModHandle()
	if _UIModStarted == nil then
		_UIModStarted = true;
			DialogList:GetDialog( "radar_dialog" ):SetVisible( false );
			DialogList:GetDialog( "subzone_name_dialog" ):SetVisible( false );
			
	else
		_UIModStarted = nil;
		DialogList:GetDialog( "radar_dialog" ):SetVisible( true );
		DialogList:GetDialog( "subzone_name_dialog" ):SetVisible( true );
	end
		
end