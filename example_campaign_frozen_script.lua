local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local BaseManager = import('/lua/ai/opai/basemanager.lua')

local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local Difficulty = ScenarioInfo.Options.Difficulty


--- Army numbers 
local Player1 = 1
local UEFAlly = 2
local UEFEnemy = 3


function OnPopulate()
    ScenarioUtils.InitializeScenarioArmies()
end

local UEFAllySouthBase = BaseManager.CreateBaseManager()

function StartMission1()

    local opai = nil
    local quantity = {}
    local trigger = {}

    -- Set the playable area
    ScenarioFramework.SetPlayableArea('M1_Playable_Area', false)

    UEFAllySouthBase:InitializeDifficultyTables(
        ArmyBrains[UEFAlly],
        'M1_South_Base',
        'M1_South_Base_Marker',
        80, 
        { M1_South_Base = 100 }
    )

    UEFAllySouthBase:StartNonZeroBase({{7, 5, 3}, {5, 4, 3}})
    UEFAllySouthBase:SetActive('AirScouting', true)


    -- # Basic bomber attack routes

    quantity = {4, 3, 2}

    ---@type OpAI
    opai = UEFAllySouthBase:AddOpAI('AirAttacks', 'M1_UEFAlly_Bomber_Attack',
        {
            MasterPlatoonFunction = {'/lua/scenarioplatoonai.lua', 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M1_UEFAlly_Attack_East_B',
            },

            Priority = 100,
        }
    )

    opai:SetChildQuantity('Bombers', quantity[Difficulty])
    -- opai:SetLockingStyle() -- 'BuildTimer', { LockTimer = 1 }

    -- # Basic interceptors for base defense

    quantity = {4, 3, 2}
    opai = UEFAllySouthBase:AddOpAI('AirAttacks', 'M1_UEFAlly_Interceptor_Defense',
        {
            MasterPlatoonFunction = { '/lua/scenarioplatoonai.lua', 'PatrolChainPickerThread' },
            PlatoonData = {
                PatrolChains = {
                    'M1_UEFAlly_Interceptor_Patrol_A',
                    'M1_UEFAlly_Interceptor_Patrol_B'
                },
            },

            Priority = 100,
        }
    )

    opai:SetChildQuantity('Interceptors', quantity[Difficulty])
    -- opai:SetLockingStyle()

    -- # Interceptors that help the command unit

    ---@type AIBrain
    quantity = {8, 6, 4}
    opai = UEFAllySouthBase:AddOpAI('AirAttacks', 'M1_UEFAlly_Interceptors_Command_Defense',
        {
            MasterPlatoonFunction = { '/maps/example_campaign_frozen/PlatoonFunctions.lua', 'InterceptorCommandDefenseBehavior' },
            PlatoonData = {
                ArmiesToProtect = { Player1 },
                CategoriesToProtect = categories.COMMAND,
                DefaultPatrolChain = 'M1_UEFAlly_Interceptor_Patrol_B',
            },

            Priority = 100,
        }
    )

    opai:SetChildQuantity('Interceptors', quantity[Difficulty])

end

function CommandUnitDeathTrigger(unit)
    LOG("CommandUnitDeathTrigger")
end

function OnStart(scenario)

    SetAlliance(Player1, UEFAlly, 'Ally')
    SetAlliance(UEFAlly, UEFEnemy, 'Enemy')
    SetAlliance(Player1, UEFEnemy, 'Enemy')

    local command = ScenarioFramework.SpawnCommander('Player1', 'Commander', 'Warp', true, true, CommandUnitDeathTrigger)

    ForkThread(
        function()
            WaitSeconds(1.0)
            StartMission1()
        end
    )




end

