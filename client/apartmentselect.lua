local BoardCoords = vector4(-44.19, -585.99, 87.71, 250.0)
local BoardModel = `tr_prop_tr_planning_board_01a`
local RenderTarget = 'modgarage_01'
local Board, scaleform, currentButtonID = nil, nil, 1

local function SetupBoard()
    while not HasModelLoaded(BoardModel) do RequestModel(BoardModel) Wait(0) end
    Board = CreateObject(BoardModel, BoardCoords.x, BoardCoords.y, BoardCoords.z, false, false, false)
    SetEntityHeading(Board, BoardCoords.w)
end

local function CreateNamedRenderTargetForModel(name, model)
	local handle = 0
	if not IsNamedRendertargetRegistered(name) then
		RegisterNamedRendertarget(name, false)
	end
	if not IsNamedRendertargetLinked(model) then
		LinkNamedRendertarget(model)
	end
	if IsNamedRendertargetRegistered(name) then
		handle = GetNamedRendertargetRenderId(name)
	end
	return handle
end

local function StartScaleform()
    scaleform = RequestScaleformMovie('AUTO_SHOP_BOARD')
    while not HasScaleformMovieLoaded(scaleform) do Wait(0) end
    CreateThread(function()
        while true do
            local Handle = CreateNamedRenderTargetForModel(RenderTarget, BoardModel)
            SetTextRenderId(Handle)
            SetScriptGfxDrawBehindPausemenu(true)
            SetScaleformFitRendertarget(scaleform, true)
            DrawScaleformMovie(scaleform, 0.25, 0.5, 0.5, 1.0, 255, 255, 255, 255, 0)
            SetTextRenderId(GetDefaultScriptRendertargetRenderId())
            SetScriptGfxDrawBehindPausemenu(false)
            Wait(0)
        end
    end)
end

local function SetupScaleform()
    -- Somehow doesn't update the screen unless you make it blank first. Even though the actionscript suggest it cleans the screen itself internally. :shrug:
    CallScaleformMovieMethod(scaleform, 'SHOW_BLANK_SCREEN')
    BeginScaleformMovieMethod(scaleform, 'SET_STYLE')
    ScaleformMovieMethodAddParamInt(3)
    EndScaleformMovieMethod()

    BeginScaleformMovieMethod(scaleform, 'SHOW_SELECTION_SCREEN')

    -- Smart math that isn't modular at all. Can't wait for the support questions for this one
    local StartingPoint
    if currentButtonID < 4 then
        StartingPoint = 1
    elseif currentButtonID < 7 then
        StartingPoint = 4
    end
    for i = StartingPoint, StartingPoint + 2 do
        ScaleformMovieMethodAddParamTextureNameString(string.format('selection%s', i))
        BeginTextCommandScaleformString('STRING')
        AddTextComponentSubstringPlayerName(Apartments[i].label)
        EndTextCommandScaleformString()
        BeginTextCommandScaleformString('STRING')
        AddTextComponentSubstringPlayerName(Apartments[i].description)
        EndTextCommandScaleformString()
        ScaleformMovieMethodAddParamInt(0)
    end

    BeginTextCommandScaleformString('STRING')
    AddTextComponentSubstringPlayerName(string.format('%s/%s', currentButtonID, #Apartments))
    EndTextCommandScaleformString()

    ScaleformMovieMethodAddParamInt(0)

    ScaleformMovieMethodAddParamBool(true)
    ScaleformMovieMethodAddParamBool(true)
    ScaleformMovieMethodAddParamBool(true)

    -- Same "modular" bullshit here. Had no success with CURRENT_SELECTION nor CURRENT_ROLLOVER, not sure why.
    for i = StartingPoint, StartingPoint + 2 do
        if i == currentButtonID then
            ScaleformMovieMethodAddParamBool(true)
        else
            ScaleformMovieMethodAddParamBool(false)
        end
    end
    EndScaleformMovieMethod()
end

local function InputHandler()
    while true do
        if IsControlJustReleased(0, 188) then
            currentButtonID = currentButtonID - 1
            if currentButtonID < 1 then currentButtonID = 1 end
            SetupScaleform()
        elseif IsControlJustReleased(0, 187) then
            currentButtonID = currentButtonID + 1
            if currentButtonID > #Apartments then currentButtonID = #Apartments end
            SetupScaleform()
        elseif IsControlJustReleased(0, 191) then
            break
        end
        Wait(0)
    end
    StopCamera()
    return currentButtonID
end

lib.callback.register('qbx-spawn:callback:chooseApartment', function()
    ManagePlayer()
    SetupCamera(true)
    SetupBoard()
    StartScaleform()
    SetupScaleform()
    return InputHandler()
end)
