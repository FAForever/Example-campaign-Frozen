
local ScenarioFramework = import('/lua/ScenarioFramework.lua')


---@class InterceptorDefenseBehaviorState
---@field Status string
---@field Unit Unit
---@field Target Unit
---@field BaseChain string
---@field Instigator Unit
local InterceptorDefenseBehaviorState = ClassSimple {

    PatrolDelay = 60,
    Debug = true,

    --- todo: comment
    ---@param state InterceptorDefenseBehaviorState
    ---@param unit Unit
    ---@param target Unit
    ---@param chain MarkerChain
    __init = function(state, unit, target, chain)

        -- safe data in state
        state.Status = 'Blank'
        state.Unit = unit
        state.Target = target
        state.BaseChain = chain

        -- setup trigger system to switch states
        if state.Target then 
            state.Target:AddOnDamagedCallback(
                function(target, instigator)
                    if not (IsDestroyed(instigator) or instigator.Dead) then 
                        if IsUnit(instigator) then
                            if EntityCategoryContains(categories.AIR, instigator) then
                                if 
                                    (state.Status == 'PatrolBase') or
                                    (state.Status == 'PatrolTarget')
                                then 
                                    state.Instigator = instigator
                                    ChangeState(state, state.ProtectTarget)
                                end
                            end
                        end
                    end
                end,
                -1,
                -1
            )

            state.Target:AddOnDamagedCallback(
                function(target, instigator)
                    if not (IsDestroyed(instigator) or instigator.Dead) then 
                        if IsUnit(instigator) then
                            if EntityCategoryContains(categories.AIR, instigator) then
                                if 
                                    (state.Status == 'PatrolBase') or
                                    (state.Status == 'PatrolTarget')
                                then 
                                    state.Instigator = instigator
                                    ChangeState(state, state.ProtectTarget)
                                end
                            end
                        end
                    end
                end,
                -1,
                -1
            )
        end

        ChangeState(state, state.PatrolBase)
    end,

    PatrolBase = State {
        Main = function(state) 

            if state.Debug then 
                LOG("PatrolBase")
            end

            state.Status = 'PatrolBase'

            IssueClearCommands({state.Unit})
            ScenarioFramework.GroupPatrolChain({ state.Unit }, state.BaseChain)
        end,
    },

    ProtectTarget = State {
        Main = function(state) 

            if state.Debug then 
                LOG("ProtectTarget")
            end

            local instigatorIsAlive = not IsDestroyed(state.Instigator)

            if instigatorIsAlive then

                state.Status = 'ProtectTarget'

                IssueClearCommands({state.Unit})
                IssueAttack({state.Unit}, state.Instigator)

                state.Instigator:AddUnitCallback(
                    function(self)
                        ChangeState(state, state.PatrolTarget)
                    end,
                    'OnKilled'
                )
            else 
                ChangeState(state, state.PatrolTarget)
            end
        end,
    },

    PatrolTarget = State {
        Main = function(state)

            if state.Debug then 
                LOG("PatrolTarget")
            end

            local targetIsAlive = not IsDestroyed(state.Target)

            if targetIsAlive then

                state.Status = 'PatrolTarget'

                IssueClearCommands({state.Unit})

                local x, y, z = state.Target:GetPositionXYZ()
                IssuePatrol({state.Unit}, { x + 20, y, z + 20})
                IssuePatrol({state.Unit}, { x - 20, y, z - 20})
            
                WaitSeconds(state.PatrolDelay)
                ChangeState(state, state.PatrolBase)
            end
        end,
    },

    Blank = State {
        Main = function(state)

            if state.Debug then 
                LOG("Blank")
            end

            state.Status = 'Blank'
        end,
    }
}

---comment
---@param platoon Platoon
function InterceptorCommandDefenseBehavior(platoon) 
    LOG("InterceptorCommandDefenseBehavior")

    ---@type number[]
    local armiesToProtect = platoon.PlatoonData.ArmiesToProtect

    ---@type Categories
    local categoriesToProtect = platoon.PlatoonData.CategoriesToProtect

    ---@type string
    local defaultPatrolChain = platoon.PlatoonData.DefaultPatrolChain

    local units = platoon:GetPlatoonUnits()

    local playerBrain = ArmyBrains[1]
    local commandUnit = playerBrain:GetListOfUnits(categoriesToProtect, false, false)[1]

    for k, unit in units do 
        InterceptorDefenseBehaviorState(unit, commandUnit, defaultPatrolChain)
    end
end