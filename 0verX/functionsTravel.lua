--[[

	--------------------------------------------------
	Copyright (C) 2011 Blastradius

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

function CheckTravelPosition()

	if TravelList == nil then
		-- Write( "No travel path has been loaded!" )
		return false;
	elseif TravelList:GetList().Count < 2 then
		-- Write( "Travel list has 0 or 1 node!" );
		return false;
	elseif TravelList:GetList().Count > 1 then
	
		local BestDistance = 100;
		local BestTravel = nil;
		
		for Travel in ListIterator( TravelList:GetList()) do
			local CurrentDistance = Player:GetPosition():DistanceToPosition( Travel:GetPosition());
			if Travel == nil or CurrentDistance < BestDistance then
				BestTravel = Travel;
				BestDistance = CurrentDistance;
			end
		end
	
		while true do
			if TravelList:GetNext() == BestTravel then
				TravelList:Move();
				return true;
			end
		end
				
	end

	return false;
	
end