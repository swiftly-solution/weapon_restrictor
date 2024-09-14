AddEventHandler("OnPluginStart", function(event)
    config:Create("weapon_restrictor", {
        prefix = "[{lime}Swiftly{default}]",
        map_restriction = {},
        per_player = {},
        per_team = {},
        enable_in_warmup = false,
        limit_per_team = false
    })
end)
