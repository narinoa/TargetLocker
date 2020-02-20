local PanelTarget = mainForm:GetChildChecked( "PanelTarget", false )
local ButtonSettings = PanelTarget:GetChildChecked( "ButtonSettings", false )
local ButtonTarget = PanelTarget:GetChildChecked( "ButtonTarget", false )
local ButtonControl = PanelTarget:GetChildChecked( "ButtonControl", false )

ButtonTarget:SetVal("button_label", userMods.ToWString('Нет цели'))
ButtonTarget:SetTextColor(nil, { a = 1, r = 1, g = 1, b = 0 })
ButtonControl:SetVal("button_label", userMods.ToWString('Нет цели'))
ButtonControl:SetTextColor(nil, { a = 1, r = 1, g = 1, b = 0 })

local Mode = 0
local SavedTarget = 0
local SavedControl = 0
local SavedTargetName
local SavedControlName


function ButtonClick(params)
if DnD:IsDragging() then return	end
--LogInfo(params.sender)
if params.sender == "ButtonSettings" then
	if Mode == 0 then
		ButtonControl:Show(true)
	Mode = 1
	else
		ButtonControl:Show(false)
	Mode = 0
	end
elseif params.sender == "ButtonTarget" then
	if params.name == "LEFT_CLICK" then
		SelectTarget(params.sender)
	elseif params.name == "RIGHT_CLICK" and params.kbFlags == 1 then
		ClearTarget(params.sender, params.widget)
	elseif params.name == "RIGHT_CLICK" then
		SaveTarget(params.sender, params.widget)
	end
elseif params.sender == "ButtonControl" then
	if params.name == "LEFT_CLICK" then
		SelectTarget(params.sender)
	elseif params.name == "RIGHT_CLICK" and params.kbFlags == 1 then
		ClearTarget(params.sender, params.widget)
	elseif params.name == "RIGHT_CLICK" then
		SaveTarget(params.sender, params.widget)
		end
	end
end

function SelectTarget(arg, wt)
if arg == "ButtonTarget" then 
	if object.IsExist(SavedTarget) and unit.CanSelectTarget(SavedTarget) then
		avatar.SelectTarget(SavedTarget)
		end
elseif arg == "ButtonControl" then 
	if object.IsExist(SavedControl) and unit.CanSelectTarget(SavedControl) then
		avatar.SelectTarget(SavedControl)
		end
	end
end

function SaveTarget(arg, wt)
if arg == "ButtonTarget" then 
	if not avatar.GetTarget() then return end
	SavedTarget = avatar.GetTarget()
		if unit.IsPet(SavedTarget) then
		SavedTargetName = object.GetName(unit.GetPetOwner(SavedTarget))
		SavedTarget = unit.GetPetOwner(SavedTarget)
		else
		SavedTargetName = object.GetName(SavedTarget)
		end
	wt:SetVal("button_label", object.GetName(SavedTarget))
	wt:SetTextColor(nil, { a = 1, r = 0, g = 1, b = 0 })
elseif arg == "ButtonControl" then 
	if not avatar.GetTarget() then return end
	SavedControl = avatar.GetTarget()
		if unit.IsPet(SavedControl) then
		SavedControlName = object.GetName(unit.GetPetOwner(SavedControl))
		SavedControl = unit.GetPetOwner(SavedControl)
		else
		SavedControlName = object.GetName(SavedControl)
		end
	wt:SetVal("button_label", object.GetName(SavedControl))
	wt:SetTextColor(nil, { a = 1, r = 0, g = 1, b = 0 })	
	end
end

function ClearTarget(arg, wt)
if arg == "ButtonTarget" then 
	SavedTarget = 0
	SavedTargetName = nil
	wt:SetVal("button_label", userMods.ToWString('Нет цели'))
	wt:SetTextColor(nil, { a = 1, r = 1, g = 1, b = 0 })
elseif arg == "ButtonControl" then 
	SavedControl = 0
	SavedControlName = nil
	wt:SetVal("button_label", userMods.ToWString('Нет цели'))
	wt:SetTextColor(nil, { a = 1, r = 1, g = 1, b = 0 })
	end
end

function DespawnUnit(params)
if params.unitId == SavedTarget then
	ButtonTarget:SetTextColor(nil, { a = 1, r = 1, g = 0, b = 0 })
elseif params.unitId == SavedControl then
	ButtonControl:SetTextColor(nil, { a = 1, r = 1, g = 0, b = 0 })
	end
end

function SpawnUnit(params)
if SavedTargetName then
if userMods.FromWString(object.GetName(params.unitId)) == userMods.FromWString(SavedTargetName) then
	SavedTarget = params.unitId
	ButtonTarget:SetTextColor(nil, { a = 1, r = 0, g = 1, b = 0 })
	end
end 
if SavedControlName then
if userMods.FromWString(object.GetName(params.unitId)) == userMods.FromWString(SavedControlName) then
	SavedControl = params.unitId
	ButtonControl:SetTextColor(nil, { a = 1, r = 0, g = 1, b = 0 })
		end 
	end
end

function DeadUnit(params)
if params.unitId == SavedTarget then
	ButtonTarget:SetTextColor(nil, { a = 1, r = 1, g = 0, b = 0 })
elseif params.unitId == SavedControl then
	ButtonControl:SetTextColor(nil, { a = 1, r = 1, g = 0, b = 0 })
	end
end

function AOLocker(params)
	if params.StatusDnD then
		DnD:Enable( PanelTarget, false )
	elseif not params.StatusDnD then
		DnD:Enable( PanelTarget, true )
	end
end

function Init()
	DnD.Init(PanelTarget,ButtonSettings, true)
	common.RegisterReactionHandler( ButtonClick, "LEFT_CLICK" )
	common.RegisterReactionHandler( ButtonClick, "RIGHT_CLICK" )
	common.RegisterEventHandler( AOLocker, "AO_LOCKER_START" )
	common.RegisterEventHandler( DeadUnit, "EVENT_UNIT_DEAD_CHANGED" )
	common.RegisterEventHandler( DespawnUnit, "EVENT_UNIT_DESPAWNED" )
	common.RegisterEventHandler( SpawnUnit, "EVENT_UNIT_SPAWNED" )
end

if (avatar.IsExist()) then Init()
else common.RegisterEventHandler(Init, "EVENT_AVATAR_CREATED")	
end