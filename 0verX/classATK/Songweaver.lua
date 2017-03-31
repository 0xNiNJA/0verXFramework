--- (Private Function) Checks the healing requirements for the provided entity.
--
-- @param	Entity	Contains the entity to perform healing on.
-- @param	double	Contains the
-- @return	bool

local DMG_CHAIN_SKILLS =
	{
		"Tsunami Requiem",
		"Variation of Peace";
		"Melody of Appreciation",
		"Flame Harmony",--"Song of Fire",--Flame Harmony
		"Wind Harmony",--"Thronesong",--Wind Harmony
		"Earth Harmony",--"Song of Earth",--Earth Harmony
		"Harmony of Death",--"Bright Stroke",--Harmony of Death
		"Acute Grating Sound",--"Fluttered Note",--Acute Grating Sound
		"Harmony of Destruction"--"Bright Flourish",--Harmony of Destruction
		--"Sonic Splash"--Tsunami Requiem
	};

local DMG_CHARGE_SKILLS =
	{
		"Fantastic Variation",
		"Illusion Variation",
		"Battle Variation",--"Fiery Descant",--Battle Variation
		"Sea Variation",
		"Ascended Soul Variation"
		--"Fiery Requiem",--Illusion Variation
		--"Dragon Song",--Ascended Soul Variation
	--	"Sea Variation"--"Harpist's Pod"--Sea Variation
	};

local DMG_SKILLS =
	{
		"Disharmony",
		"Gust Requiem",--"Sonic Gust",--Gust Requiem
		"Mosky Requiem",
		"Soul Harmony",
		"Chilling Harmony",--"Song of Ice",--Chilling Harmony
		--"Bright Strike"--Soul Harmony
		"Sound of Breeze"
	};
	
local HEAL_CHAIN_SKILLS =
	{
		"Melody of Joy",--"Joyous Carol",--Melody of Joy
		"Soft Echo",
		"Mild Echo"--"Soothing Counterpoint",--Mild Echo
		--"Hymn of Thanksgiving"--Melody of Appreciation
	};

function _ExecuteSkillFromList(Entity, Skills)
	for k, Skill  in ipairs(Skills) do
		if Helper:CheckAvailable( Skill ) then
			Helper:CheckExecute( Skill, Entity );
			--return false;
		end
	end
	return true;
end

function _ExecuteSkillFromList(Player, Skills)
	for k, Skill  in ipairs(Skills) do
		if Helper:CheckAvailable( Skill ) then
			Helper:CheckExecute( Skill, Player );
			--return false;
		end
	end
	return true;
end

function GetBuff() --belirleme

	-- Loop through the state of the target entity 
	for i = 0, Player:GetState():GetStateSize() - 1, 1 do
	
		-- Retrieve the state from the EntityState.
		local StateIndex = Player:GetState():GetStateIndex( i );

		-- Check if the state is correct and check if it is a debuff.
		if StateIndex ~= nil and StateIndex:IsDebuff() then		
			return true;			
		end
		
	end
	
end
function GetBufff(Entity) --belirleme

	-- Loop through the state of the target entity 
	for i = 0, Entity:GetState():GetStateSize() - 1, 1 do
	
		-- Retrieve the state from the EntityState.
		local StateIndex = Entity:GetState():GetStateIndex( i );

		-- Check if the state is correct and check if it is a debuff.
		if StateIndex ~= nil and StateIndex:IsDebuff() then		
			return true;			
		end
		
	end
	
end


function Attack( Entity, Range, Stunned )

  -- Get Infos about current situation
	local EntityHealth = Entity:GetHealth();
	local EntityDistance = Player:GetPosition():DistanceToPosition( Entity:GetPosition() );
	local EntityAggro = Player:GetPosition():DistanceToPosition( Entity:GetPosition() );
	local PlayerID = Player:GetID();
	local EntityTargetID = Entity:GetTargetID();
	local Range = Player:GetPosition():DistanceToPosition( Entity:GetPosition());
		
if not string.find(Entity:GetName() , "Statue") then
	-- Check Chain Skills first
	if(not self:_ExecuteSkillFromList(Entity, DMG_CHAIN_SKILLS)) then
		--return false;
	end
	
	self:CheckAttackFood();
	
	-- Use Remove Shock
	if Helper:CheckAvailable( "Remove Shock" ) then
		Helper:CheckExecute( "Remove Shock" );
		--return false;
	end
	
  if Helper:CheckAvailable( "Melody of Appreciation" ) and Player:GetHealth() < 50 then
		Helper:CheckExecute( "Melody of Appreciation" );
		--return false;
	elseif Helper:CheckAvailable( "Shock Blast" ) then
		Helper:CheckExecute( "Shock Blast" );
		--return false;
	end
	
	if Helper:CheckAvailable( "Symphony of Destruction" ) and Player:GetDP() >=2000 then
		Helper:CheckExecute( "Symphony of Destruction");
		--return false;
	end
	
	if EntityHealth == 100 and Helper:CheckAvailable( "Melody of Cheer" ) then--Loud Bang "Adagio"
		Helper:CheckExecute( "Melody of Cheer", Player );
		--return false;
	end	
	
	if Player:GetMana() <= 70 and Player:GetHealth() > 50 and Helper:CheckAvailable( "Melody of Reflection" ) then
		Helper:CheckExecute( "Melody of Reflection", Player );
		--return false;
	end
	
	if Player:GetMana() <= 40 and Player:GetHealth() > 50 and Helper:CheckAvailable( "Echo of Clarity" ) then
		Helper:CheckExecute( "Echo of Clarity", Player );
		--return false;
	end
	
	--DEFANS
	for ID, Entity in DictionaryIterator( EntityList:GetList()) do
		if Entity:GetSkillID() ~= 0 and Entity:GetTargetID() == Player:GetID() then

			local Skill = SkillList:GetSkill( Entity:GetSkillID());
				if Skill ~= nil and Skill:IsMagical() and Helper:CheckAvailable( "Harmony of Silence" ) and Entity:GetSkillTime() >= 500 then --Range <= 10 and 
					Helper:CheckExecute( "Harmony of Silence" );
					return false
				end
		end
	end
	
	
	if Player:GetHealth() < 80 and Helper:CheckAvailable( "Rejuvenation Melody" ) then
		Helper:CheckExecute( "Rejuvenation Melody", Player );
		--return false;
	end
	
	-- Check Chain Skills first
	if Player:GetHealth() < 90 and (not self:_ExecuteSkillFromList(Player, HEAL_CHAIN_SKILLS)) then
		--return false;
	end
	
	if Player:GetHealth() < 51 and Helper:CheckAvailable( "Gentle Echo" ) then
		Helper:CheckExecute( "Gentle Echo", Player );
		--return false;
	end
	
	if self:GetBuff() and Helper:CheckAvailable( "Melody of Purification" ) then
		Helper:CheckExecute( "Melody of Purification", Player );
		--return false;
	end
	
	-- Snowflower Melody
	if Helper:CheckAvailable( "Snowflower Melody" ) and Player:GetHealth() < 40 then
		Helper:CheckExecute( "Snowflower Melody" );
		--return false;
	end
	
	-- Shield Melody
	if Entity:GetHealth() > 0 and Helper:CheckAvailable( "Shield Melody" ) and Player:GetState():GetState( 4442 ) == nil then
		Helper:CheckExecute( "Shield Melody", Player );
		--return false;
	end

	-- Dot Skill if we didn't engage him
	if EntityHealth == 100  then
		if Helper:CheckAvailable( "Attack Resonation" ) then--Attack Resonation "Syncopated Echo"
			Helper:CheckExecute( "Attack Resonation", Entity );
			--return false;
		end
	end
	
	-- Wind Harmony
	if Player:GetState():GetState( "Wind Harmony") == nil and Helper:CheckAvailable( "Chilling Harmony" ) then
		Helper:CheckExecute( "Chilling Harmony" )
		--return false;
	end
	
	-- Slow Target
	if Helper:CheckAvailable( "Loud Bang" ) then--Loud Bang "Adagio"
		Helper:CheckExecute( "Loud Bang", Entity );
		--return false;
	end
	
	if Helper:CheckAvailable( "Gust Requiem" ) then
		Helper:CheckExecute( "Gust Requiem", Entity );
		--return false;
	end
		
	--  Use Charge Skills
	if EntityHealth >= 50  then
		-- Check Chain Skills first
		if Range >= 7 and (not self:_ExecuteSkillFromList(Entity, DMG_CHARGE_SKILLS)) then
			--return false;
		end
	end
	
	if Helper:CheckAvailable( "Disharmony" ) then
		Helper:CheckExecute( "Disharmony", Entity );
		--return false;
	end
	
	if Helper:CheckAvailable( "March of the Bees" ) then
		Helper:CheckExecute( "March of the Bees", Entity );
		--return false;
	end
		
	if EntityHealth >= 90 and Helper:CheckAvailable( "Mosky Requiem" ) then
		Helper:CheckExecute( "Mosky Requiem", Entity );
		--return false;
	end
	
	if Helper:CheckAvailable( "Symphony of Wrath" ) and Player:GetDP() >=2000 then
		Helper:CheckExecute( "Symphony of Wrath");
		--return false;
	end
	
			
	if Helper:CheckAvailable( "Chilling Harmony" ) then
		Helper:CheckExecute( "Chilling Harmony", Entity );
		--return false;
	end
	
	if Helper:CheckAvailable( "Soul Harmony" ) then
		Helper:CheckExecute( "Soul Harmony", Entity );
		--return false;
	end

		
	if Helper:CheckAvailable( "Sound of the Breeze" ) then--Sound of the Breeze "Pulse"
		Helper:CheckExecute( "Sound of the Breeze", Entity );
		--return false;
	end
end
	
	-- Nothing was executed, continue with other functions.
	return not self:_ExecuteSkillFromList(Entity, DMG_CHARGE_SKILLS);
end


function Pause()

	self:CheckAttackFood();
  
	if Player:GetHealth() < 95 and (not self:_ExecuteSkillFromList(Player, HEAL_CHAIN_SKILLS)) then
		--return false;
	end
	
	-- Shield Melody
	if Helper:CheckAvailable( "Shield Melody" ) and Player:GetState():GetState( 4442 ) == nil then
		Helper:CheckExecute( "Shield Melody", Player );
		--return false;
	end
	
	if Player:GetHealth() < 70 and Helper:CheckAvailable( "Gentle Echo" ) then
		Helper:CheckExecute( "Gentle Echo", Player );
		--return false;
	end
	
	if Player:GetMana() <= 70 and Helper:CheckAvailable( "Melody of Reflection" ) then
		Helper:CheckExecute( "Melody of Reflection", Player );
		--return false;
	end
	
	if Player:GetMana() <= 40 and Helper:CheckAvailable( "Echo of Clarity" ) then
		Helper:CheckExecute( "Echo of Clarity", Player );
		--return false;
	end
	
	if Player:GetState():GetState( "Melody of Life" ) == nil and Player:GetState():GetState( "Prayer of Protection" ) == nil and Player:GetState():GetState( "Blessing of Rock" ) == nil and Player:GetState():GetState( "Blessing of Stone" ) == nil and Helper:CheckAvailable( "Melody of Life" ) then
		Helper:CheckExecute( "Melody of Life", Player )
		--return false;
	end
	
	-- Nothing was executed, continue with other functions.
	--return true;

end

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