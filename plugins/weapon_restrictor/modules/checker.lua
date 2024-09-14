ItemDefIndex = {
    [1] = { "weapon_deagle", gear_slot_t.GEAR_SLOT_PISTOL },
    [2] = { "weapon_elite", gear_slot_t.GEAR_SLOT_PISTOL },
    [3] = { "weapon_fiveseven", gear_slot_t.GEAR_SLOT_PISTOL },
    [4] = { "weapon_glock", gear_slot_t.GEAR_SLOT_PISTOL },
    [7] = { "weapon_ak47", gear_slot_t.GEAR_SLOT_RIFLE },
    [8] = { "weapon_aug", gear_slot_t.GEAR_SLOT_RIFLE },
    [9] = { "weapon_awp", gear_slot_t.GEAR_SLOT_RIFLE },
    [10] = { "weapon_famas", gear_slot_t.GEAR_SLOT_RIFLE },
    [11] = { "weapon_g3sg1", gear_slot_t.GEAR_SLOT_RIFLE },
    [13] = { "weapon_galilar", gear_slot_t.GEAR_SLOT_RIFLE },
    [14] = { "weapon_m249", gear_slot_t.GEAR_SLOT_RIFLE },
    [16] = { "weapon_m4a1", gear_slot_t.GEAR_SLOT_RIFLE },
    [17] = { "weapon_mac10", gear_slot_t.GEAR_SLOT_RIFLE },
    [19] = { "weapon_p90", gear_slot_t.GEAR_SLOT_RIFLE },
    [23] = { "weapon_mp5sd", gear_slot_t.GEAR_SLOT_RIFLE },
    [24] = { "weapon_ump45", gear_slot_t.GEAR_SLOT_RIFLE },
    [25] = { "weapon_xm1014", gear_slot_t.GEAR_SLOT_RIFLE },
    [26] = { "weapon_bizon", gear_slot_t.GEAR_SLOT_RIFLE },
    [27] = { "weapon_mag7", gear_slot_t.GEAR_SLOT_RIFLE },
    [28] = { "weapon_negev", gear_slot_t.GEAR_SLOT_RIFLE },
    [29] = { "weapon_sawedoff", gear_slot_t.GEAR_SLOT_RIFLE },
    [30] = { "weapon_tec9", gear_slot_t.GEAR_SLOT_PISTOL },
    [32] = { "weapon_hkp2000", gear_slot_t.GEAR_SLOT_PISTOL },
    [33] = { "weapon_mp7", gear_slot_t.GEAR_SLOT_RIFLE },
    [34] = { "weapon_mp9", gear_slot_t.GEAR_SLOT_RIFLE },
    [35] = { "weapon_nova", gear_slot_t.GEAR_SLOT_RIFLE },
    [36] = { "weapon_p250", gear_slot_t.GEAR_SLOT_PISTOL },
    [38] = { "weapon_scar20", gear_slot_t.GEAR_SLOT_RIFLE },
    [39] = { "weapon_sg556", gear_slot_t.GEAR_SLOT_RIFLE },
    [40] = { "weapon_ssg08", gear_slot_t.GEAR_SLOT_RIFLE },
    [60] = { "weapon_m4a1_silencer", gear_slot_t.GEAR_SLOT_RIFLE },
    [61] = { "weapon_usp_silencer", gear_slot_t.GEAR_SLOT_PISTOL },
    [63] = { "weapon_cz75a", gear_slot_t.GEAR_SLOT_PISTOL },
    [64] = { "weapon_revolver", gear_slot_t.GEAR_SLOT_PISTOL },
}

local countCache = {}

--- @param itemidx number
--- @return number
function GetSlotByIdx(itemidx)
    return ItemDefIndex[itemidx][2]
end

--- @param weapons table
--- @param slot number
--- @return boolean
function ExistsWeaponInSlot(weapons, slot)
    for i = 1, #weapons do
        --- @type Weapon
        local weapon = weapons[i]
        if weapon:CCSWeaponBaseVData().GearSlot == slot then
            return true
        end
    end

    return false
end

--- @param itemidx number
--- @return number
function GetWeaponCountByIdx(itemidx)
    if not countCache[itemidx] then countCache[itemidx] = { count = 0, time = GetTime() - 500 } end

    if GetTime() - countCache[itemidx].time >= 500 then
        for i = 1, playermanager:GetPlayerCap() do
            local player = GetPlayer(i - 1)
            if player then
                local weapons = player:GetWeaponManager():GetWeapons()
                for j = 1, #weapons do
                    --- @type Weapon
                    local weapon = weapons[j]
                    if weapon:CBasePlayerWeapon().Parent.AttributeManager.Item.ItemDefinitionIndex == itemidx then
                        countCache[itemidx].count = countCache[itemidx].count + 1
                    end
                end
            end
        end
        countCache[itemidx].time = GetTime()
    end

    return countCache[itemidx].count
end

--- @param itemidx number
--- @param t string
--- @return number
function GetWeaponCountByIdxOnTeam(itemidx, t)
    if not countCache[itemidx] then countCache[itemidx] = {} end
    if not countCache[itemidx][t] then countCache[itemidx][t] = { count = 0, time = GetTime() - 500 } end

    if GetTime() - countCache[itemidx][t].time >= 500 then
        local players = FindPlayersByTarget(t, false)
        for i=1,#players do
            --- @type Player
            local player = players[i]
            local weapons = player:GetWeaponManager():GetWeapons()
            for j = 1, #weapons do
                --- @type Weapon
                local weapon = weapons[j]
                if weapon:CBasePlayerWeapon().Parent.AttributeManager.Item.ItemDefinitionIndex == itemidx then
                    countCache[itemidx][t].count = countCache[itemidx][t].count + 1
                end
            end
        end
        countCache[itemidx][t].time = GetTime()
    end

    return countCache[itemidx][t].count
end

--- @param weapon_name string
--- @param teamstr string
--- @return number
function GetWeaponMax(weapon_name, teamstr)
    if config:Fetch("weapon_restrictor.limit_per_team") then
        if not config:Exists("weapon_restrictor.per_team." .. weapon_name) then return -1 end

        --- @type number
        local max = -1
        local weaponData = config:Fetch("weapon_restrictor.per_team." .. weapon_name)
    
        if weaponData[teamstr] then max = (tonumber(weaponData[teamstr]) or -1) end
        return max
    else
        if not config:Exists("weapon_restrictor.per_player." .. weapon_name) then return -1 end

        --- @type number
        local max = -1
        local weaponData = config:Fetch("weapon_restrictor.per_player." .. weapon_name)
    
        if weaponData.default then max = (tonumber(weaponData.default) or -1) end
        local players = playermanager:GetPlayerCount()
    
        for k, v in next, weaponData, nil do
            local pcount = tonumber(k)
            if pcount ~= nil then
                if pcount <= players then
                    max = (tonumber(v) or -1)
                end
            end
        end
    
        return max
    end
end

--- @param weapon_name string
--- @param team number
--- @return number
function GetWeaponMaxPerTeam(weapon_name, team)
    local teamstr = (team == Team.T and "T" or "CT")
    if not config:Exists("weapon_restrictor.per_team." .. weapon_name) then return -1 end

    --- @type number
    local max = -1
    local weaponData = config:Fetch("weapon_restrictor.per_team." .. weapon_name)

    if weaponData[teamstr] then max = (tonumber(weaponData[teamstr]) or -1) end
    local players = #FindPlayersByTarget("@" .. (teamstr:lower()), false)

    for k, v in next, weaponData, nil do
        local pcount = tonumber(k)
        if pcount ~= nil then
            if pcount <= players then
                max = (tonumber(v) or -1)
            end
        end
    end

    return max
end

--- @param player Player
--- @param itemidx integer
--- @return boolean
function CanGetWeapon(player, itemidx)
    if not ItemDefIndex[itemidx] then return true end

    local weapons = player:GetWeaponManager():GetWeapons()
    if ExistsWeaponInSlot(weapons, GetSlotByIdx(itemidx)) then return true end

    local map = server:GetMap()
    if config:Exists(string.format("weapon_restrictor.map_restriction.%s", map)) then
        local restrictedWeapons = config:Fetch(string.format("weapon_restrictor.map_restriction.%s", map))
        local some = ItemDefIndex[itemidx][1]

        for i = 1, #restrictedWeapons do
            if restrictedWeapons[i] == some then
                return true
            end
        end
    end

    local maxcount = GetWeaponMax(ItemDefIndex[itemidx][1], (player:CBaseEntity().TeamNum == Team.T and "t" or "ct"))
    if maxcount == 0 then return false end

    if config:Fetch("weapon_restrictor.limit_per_team") then
        local team = (player:CBaseEntity().TeamNum == Team.T and "@t" or "@ct")
        if GetWeaponCountByIdxOnTeam(itemidx, team) < maxcount or maxcount == -1 then
            countCache[itemidx][team].count = countCache[itemidx][team].count + 1
            return true
        end
    else
        if GetWeaponCountByIdx(itemidx) < maxcount or maxcount == -1 then
            countCache[itemidx].count = countCache[itemidx].count + 1
            return true
        end
    end

    return false
end
