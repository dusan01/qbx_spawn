local scaleform
local currentButtonID, previousButtonID = 1, 1

local function SetupMap()
    scaleform = RequestScaleformMovie('HEISTMAP_MP')
    CreateThread(function()
        while not HasScaleformMovieLoaded(scaleform) do Wait(0) end
        while true do
            DrawScaleformMovie_3d(scaleform, -24.86, -593.38, 91.8, -180.0, -180.0, -20.0, 0.0, 2.0, 0.0, 3.815, 2.27, 1.0, 2)
            Wait(0)
        end
    end)
end

local function SetupScaleform()
    for i = 1, #Spawns do
        CallScaleformMovieMethodWithNumber(scaleform, 'ADD_POSTIT', i, i, Spawns[i].coords.x, Spawns[i].coords.y, -1.0)
    end
    BeginScaleformMovieMethod(scaleform, 'ADD_HIGHLIGHT')
    ScaleformMovieMethodAddParamInt(1)
    ScaleformMovieMethodAddParamFloat(Spawns[1].coords.x)
    ScaleformMovieMethodAddParamFloat(Spawns[1].coords.y)
    ScaleformMovieMethodAddParamFloat(500.0)
    ScaleformMovieMethodAddParamInt(255)
    ScaleformMovieMethodAddParamInt(0)
    ScaleformMovieMethodAddParamInt(0)
    ScaleformMovieMethodAddParamInt(100)
    EndScaleformMovieMethod()
    BeginScaleformMovieMethod(scaleform, 'ADD_TEXT')
    ScaleformMovieMethodAddParamInt(1)
    ScaleformMovieMethodAddParamTextureNameString(Spawns[1].label)
    ScaleformMovieMethodAddParamFloat(Spawns[1].coords.x)
    ScaleformMovieMethodAddParamFloat(Spawns[1].coords.y - 400)
    ScaleformMovieMethodAddParamFloat(25 - math.random(0, 50))
    ScaleformMovieMethodAddParamInt(22)
    EndScaleformMovieMethod()
end

local function UpdateScaleform()
    if previousButtonID == currentButtonID then return end
    BeginScaleformMovieMethod(scaleform, 'REMOVE_HIGHLIGHT')
    ScaleformMovieMethodAddParamInt(1)
    EndScaleformMovieMethod()

    BeginScaleformMovieMethod(scaleform, 'ADD_HIGHLIGHT')
    ScaleformMovieMethodAddParamInt(1)
    ScaleformMovieMethodAddParamFloat(Spawns[currentButtonID].coords.x)
    ScaleformMovieMethodAddParamFloat(Spawns[currentButtonID].coords.y)
    ScaleformMovieMethodAddParamFloat(500.0)
    ScaleformMovieMethodAddParamInt(255)
    ScaleformMovieMethodAddParamInt(0)
    ScaleformMovieMethodAddParamInt(0)
    ScaleformMovieMethodAddParamInt(100)
    EndScaleformMovieMethod()

    BeginScaleformMovieMethod(scaleform, 'REMOVE_TEXT')
    ScaleformMovieMethodAddParamInt(1)
    EndScaleformMovieMethod()

    BeginScaleformMovieMethod(scaleform, 'ADD_TEXT')
    ScaleformMovieMethodAddParamInt(1)
    ScaleformMovieMethodAddParamTextureNameString(Spawns[currentButtonID].label)
    ScaleformMovieMethodAddParamFloat(Spawns[currentButtonID].coords.x)
    ScaleformMovieMethodAddParamFloat(Spawns[currentButtonID].coords.y - 400)
    ScaleformMovieMethodAddParamFloat(25 - math.random(0, 50))
    ScaleformMovieMethodAddParamInt(22)
    ScaleformMovieMethodAddParamInt(220)
    EndScaleformMovieMethod()
end

local function InputHandler()
    while true do
        if IsControlJustReleased(0, 188) then
            previousButtonID = currentButtonID
            currentButtonID = currentButtonID - 1
            if currentButtonID < 1 then currentButtonID = 1 end
            UpdateScaleform()
        elseif IsControlJustReleased(0, 187) then
            previousButtonID = currentButtonID
            currentButtonID = currentButtonID + 1
            if currentButtonID > #Spawns then currentButtonID = #Spawns end
            UpdateScaleform()
        elseif IsControlJustReleased(0, 191) then
            break
        end
        Wait(0)
    end
    StopCamera()
    return currentButtonID
end

lib.callback.register('qbx-spawn:callback:chooseSpawn', function(fullSpawnList)
    Spawns = fullSpawnList
    ManagePlayer()
    SetupCamera(false)
    SetupMap()
    Wait(50)
    SetupScaleform()
    return InputHandler()
end)
