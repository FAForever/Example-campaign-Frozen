version = 3 -- Lua Version. Dont touch this
ScenarioInfo = {
    name = "Example campaign: Frozen",
    description = "Due to a recent nuclear war throwing particulate matter into the air, Lake Karalcha on 14 Cygni C is frozen over for most of the year. However, there is fresh water underneath the solid two metres of surface ice, even in the middle of winter, which a valuable resource for commanders to fight over. Make sure to pack your parka.",
    preview = '',
    map_version = 3,
    type = 'campaign_coop',
    starts = true,
    size = {1024, 1024},
    reclaim = {43730.37, 61936},
    map = '/maps/example_campaign_frozen/example_campaign_frozen.scmap',
    save = '/maps/example_campaign_frozen/example_campaign_frozen_save.lua',
    script = '/maps/example_campaign_frozen/example_campaign_frozen_script.lua',
    norushradius = 40,
    Configurations = {
        ['standard'] = {
            teams = {
                {
                    name = 'FFA',
                    armies = {'Player1', 'UEFAlly', 'UEFEnemy'}
                },
            },
            customprops = {
                ['ExtraArmies'] = STRING( 'ARMY_17 NEUTRAL_CIVILIAN' ),
            },
        },
    },
}
