export("SetPlayerImmunity", function(playerid, immunitystatus)
    local player = GetPlayer(playerid)
    if not player then return end

    player:SetVar("weapon_restriction.immunity", immunitystatus)
end)
