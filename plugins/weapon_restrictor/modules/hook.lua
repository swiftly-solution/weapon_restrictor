local canAquireMem = Memory()
canAquireMem:LoadFromSignatureName("CCSPlayer_CanAcquire")
local canAquireHook = AddHook(canAquireMem, "ppup", "u")

local AcquireResult = {
    Allowed = 0,
    InvalidItem = 1,
    AlreadyOwned = 2,
    AlreadyPurchased = 3,
    ReachedGrenadeTypeLimit = 4,
    ReachedGrenadeTotalLimit = 5,
    NotAllowedByTeam = 6,
    NotAllowedByMap = 7,
    NotAllowedByMode = 8,
    NotAllowedForPurchase = 9,
    NotAllowedByProhibition = 10,
}

local AcquireMethod = {
    PickUp = 0,
    Buy = 1,
}

--- @param event Event
AddPreHookListener(canAquireHook, function(event)
    if GetCCSGameRules().WarmupPeriod and not config:Fetch("weapon_restrictor.enable_in_warmup") then return end
    local player = GetPlayer(CCSPlayerPawnBase(CCSPlayer_ItemServices(event:GetHookPointer(0):GetPtr()).Parent.Parent:GetPawn():ToPtr()).OriginalController.Parent:EntityIndex() - 1)
    if not player then return end
    local playerid = player:GetSlot()
    if player:GetVar("weapon_restriction.immunity") then return end

    local itemidx = CEconItemView(event:GetHookPointer(1):GetPtr()).ItemDefinitionIndex

    if not CanGetWeapon(player, itemidx) then
        event:SetHookReturn(event:GetHookUInt(2) == AcquireMethod.Buy and AcquireResult.AlreadyOwned or
            AcquireResult.NotAllowedByProhibition)

        if not player:GetVar("weapon_restrictor.lastinteraction." .. itemidx) then
            player:SetVar(
                "weapon_restrictor.lastinteraction." .. itemidx, GetTime() - 500)
        end

        if GetTime() - player:GetVar("weapon_restrictor.lastinteraction." .. itemidx) >= 500 then
            ReplyToCommand(playerid, config:Fetch("weapon_restrictor.prefix"),
                FetchTranslation("weapon_restrict.cannot_pickup"):gsub("{LIMIT}",
                    GetWeaponMax(ItemDefIndex[itemidx][1], player:CBaseEntity().TeamNum == Team.T and "t" or "ct")):gsub("{WEAPON_NAME}", ItemDefIndex[itemidx][1]))
            CBaseEntity(player:CCSPlayerController():ToPtr()):EmitSound("Vote.Failed", 1.0, 0.75)
        end

        player:SetVar(
            "weapon_restrictor.lastinteraction." .. itemidx, GetTime())

        return EventResult.Handled
    end
end)
