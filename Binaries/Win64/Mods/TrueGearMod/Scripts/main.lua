local truegear = require "truegear"

local hookIds = {}
local resetHook = true
local leftHandItem = nil
local rightHandItem = nil
local leftMeleeTime = 0
local rightMeleeTime = 0
local leftHandTouchTime = 0
local rightHandTouchTime = 0
local currentHP = 0
local totalHP = 0
local isPause = false


function SendMessage(context)
	if context then
		print(context .. "\n")
		return
	end
	print("nil\n")
end


function RegisterHooks()

	for k,v in pairs(hookIds) do
		UnregisterHook(k, v.id1, v.id2)
	end
		
	hookIds = {}
	
	local funcName = "/Script/Hellsplit_Arena.HSPlayerStatsComponent:HandleDeath"
	local hook1, hook2 = RegisterHook(funcName, PlayerDeath)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }
	
	local funcName = "/Script/Hellsplit_Arena.HSPlayerAvatar:PhysicalHit"
	local hook1, hook2 = RegisterHook(funcName, PhysicalHit)	
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	local funcName = "/Script/Hellsplit_Arena.HSPlayerAvatar:Heal"
	local hook1, hook2 = RegisterHook(funcName, Heal)	
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	local funcName = "/Script/Hellsplit_Arena.HSPlayerAvatar:EquipArmor"
	local hook1, hook2 = RegisterHook(funcName, EquipArmor)	
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	local funcName = "/Script/Hellsplit_Arena.HSGunBarrelComponent:Shot"
	local hook1, hook2 = RegisterHook(funcName, Shot)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	local funcName = "/Script/Hellsplit_Arena.HSHolderBasedInventorySlot:OnActorHeld"
	local hook1, hook2 = RegisterHook(funcName, OnActorHeld)	
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }
	
	local funcName = "/Script/Hellsplit_Arena.HSHolderBasedInventorySlot:OnActorReleased"
	local hook1, hook2 = RegisterHook(funcName, OnActorReleased)	
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	local funcName = "/Script/Hellsplit_Arena.HSUnarmedCombatComponent:OnChangeHandState"
	local hook1, hook2 = RegisterHook(funcName, OnChangeHandState)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	-- local funcName = "/Script/Hellsplit_Arena.HSWeaponBase:OnStabbed"
	-- local hook1, hook2 = RegisterHook(funcName, OnStabbed)
	-- hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	local funcName = "/Script/Hellsplit_Arena.HSArrowBase:OnStab"
	local hook1, hook2 = RegisterHook(funcName, ArrowOnStabbed)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	local funcName = "/Script/Hellsplit_Arena.HSWeaponBase:OnBuffActivated"
	local hook1, hook2 = RegisterHook(funcName, OnBuffActivated)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	local funcName = "/Script/Hellsplit_Arena.HSHitHandlerBase:NotifyHit"
	local hook1, hook2 = RegisterHook(funcName, WeaponMeleeHit)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	local funcName = "/Script/Hellsplit_Arena.HSArrowBase:OnReleased"
	local hook1, hook2 = RegisterHook(funcName, ArrowOnReleased)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	local funcName = "/Script/Hellsplit_Arena.HSHitChannelProviderCollision:OnComponentHit"
	local hook1, hook2 = RegisterHook(funcName, OnComponentHit)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	local funcName = "/Game/Blueprints/Common/BP_PauseMenu.BP_PauseMenu_C:ReceiveBeginPlay"
	local hook1, hook2 = RegisterHook(funcName, Pause)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	local funcName = "/Game/Blueprints/Common/BP_PauseMenu.BP_PauseMenu_C:FinishSelf"
	local hook1, hook2 = RegisterHook(funcName, UnPause)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	local funcName = "/Game/Blueprints/General/BP_HSGameInstance.BP_HSGameInstance_C:ExitToGameModeMenu"
	local hook1, hook2 = RegisterHook(funcName, ExitToGameModeMenu)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }
	
end

-- *******************************************************************

function Pause(self)
	SendMessage(self:get():GetFullName())
	isPause = true
end

function UnPause(self)
	SendMessage(self:get():GetFullName())
	isPause = false
end

function ExitToGameModeMenu(self)
	SendMessage(self:get():GetFullName())
	isPause = false
	currentHP = 0
	totalHP = 0
end





function OnComponentHit(self)
	local touchActor = self:get():GetPropertyValue("OwningActor"):GetFullName()
	if leftHandItem == touchActor and leftHandItem ~= nil then
		if os.clock() - leftHandTouchTime > 0.1 then
			SendMessage("--------------------------------")
			SendMessage("LeftHandTouch")
			truegear.play_effect_by_uuid("LeftHandPickupItem")
			SendMessage(self:get():GetFullName())
		end
		leftHandTouchTime = os.clock()
	end
	if rightHandItem == touchActor and rightHandItem ~= nil then
		if os.clock() - rightHandTouchTime > 0.1 then
			SendMessage("--------------------------------")
			SendMessage("RightHandTouch")
			truegear.play_effect_by_uuid("RightHandPickupItem")
			SendMessage(self:get():GetFullName())
		end
		rightHandTouchTime = os.clock()
	end
end


function WeaponMeleeHit(self)
	local hitWeapon = self:get():GetPropertyValue("OwningWeapon"):GetFullName()
	if leftHandItem == hitWeapon and leftHandItem ~= nil then	
		if os.clock() - leftMeleeTime > 0.1 then
			SendMessage("--------------------------------")
			SendMessage("LeftHandMeleeHit")
			truegear.play_effect_by_uuid("LeftHandMeleeHit")	
			SendMessage(self:get():GetFullName())
			SendMessage(self:get():GetPropertyValue("OwningWeapon"):GetFullName())	
			SendMessage(os.clock())
		end
		leftMeleeTime = os.clock()			
	end
	if rightHandItem == hitWeapon and rightHandItem ~= nil then
		if os.clock() - rightMeleeTime > 0.1 then
			SendMessage("--------------------------------")
			SendMessage("RightHandMeleeHit")
			truegear.play_effect_by_uuid("RightHandMeleeHit")	
			SendMessage(self:get():GetFullName())
			SendMessage(self:get():GetPropertyValue("OwningWeapon"):GetFullName())	
			SendMessage(os.clock())
		end
		rightMeleeTime = os.clock()
	end

end



function ArrowOnReleased(self)
	if self:get():GetPropertyValue("Bow"):GetFullName() == leftHandItem and leftHandItem ~= nil then
		SendMessage("--------------------------------")
		SendMessage("RightHandShootArrow")
		truegear.play_effect_by_uuid("RightHandShootArrow")	
	elseif self:get():GetPropertyValue("Bow"):GetFullName() == rightHandItem and rightHandItem ~= nil then
		SendMessage("--------------------------------")
		SendMessage("LeftHandShootArrow")
		truegear.play_effect_by_uuid("LeftHandShootArrow")	
	end
	-- SendMessage(self:get():GetFullName())
	-- SendMessage(tostring(self:get():GetPropertyValue("AlignPitchToVelocityInterpSpeed")))
	-- SendMessage(tostring(self:get():GetPropertyValue("Bow"):GetFullName()))
end


function OnBuffActivated(self)
	if leftHandItem == self:get():GetFullName() then
		SendMessage("--------------------------------")
		SendMessage("LeftHandWeaponAddBuff")
		truegear.play_effect_by_uuid("LeftHandWeaponAddBuff")	
	end
	if rightHandItem == self:get():GetFullName() then
		SendMessage("--------------------------------")
		SendMessage("RightHandWeaponAddBuff")
		truegear.play_effect_by_uuid("RightHandWeaponAddBuff")	
	end
	
	-- SendMessage(self:get():GetFullName())
end



function ArrowOnStabbed(self)
	if leftHandItem == self:get():GetFullName() then
		SendMessage("--------------------------------")
		SendMessage("LeftHandArrowOnStabbed")	
		truegear.play_effect_by_uuid("LeftHandArrowOnStabbed")	
		SendMessage(self:get():GetFullName())
	end
	if rightHandItem == self:get():GetFullName() then
		SendMessage("--------------------------------")
		SendMessage("RightHandArrowOnStabbed")	
		truegear.play_effect_by_uuid("RightHandArrowOnStabbed")	
		SendMessage(self:get():GetFullName())
	end
	
end



function OnChangeHandState(self,NewState,hand)
	-- SendMessage("--------------------------------")
	-- SendMessage("OnChangeHandState")
	-- SendMessage(self:get():GetFullName())
	-- SendMessage(tostring(NewState:get()["State"]))
	-- SendMessage(tostring(hand:get()))
	if hand:get() == 1 then
		if NewState:get()["State"] == 2 then
			SendMessage("--------------------------------")
			SendMessage("RightHandPickupItem")
			SendMessage("RightHandItem :" .. self:get():GetPropertyValue("RightController"):GetPropertyValue("UsedActor"):GetFullName())
			rightHandItem = self:get():GetPropertyValue("RightController"):GetPropertyValue("UsedActor"):GetFullName()
			truegear.play_effect_by_uuid("RightHandPickupItem")
		else
			rightHandItem = nil
		end		
	elseif  hand:get() == 0 then
		if NewState:get()["State"] == 2 then
			SendMessage("--------------------------------")
			SendMessage("LeftHandPickupItem")
			SendMessage("LeftHandItem :" .. self:get():GetPropertyValue("LeftController"):GetPropertyValue("UsedActor"):GetFullName())
			leftHandItem = self:get():GetPropertyValue("LeftController"):GetPropertyValue("UsedActor"):GetFullName()
			truegear.play_effect_by_uuid("LeftHandPickupItem")
		else
			leftHandItem = nil
		end		
	end
end








function OnActorHeld(self)
	local slotName = self:get():GetFullName()
	if string.find(slotName,"SpinetRightSlot") then
		SendMessage("--------------------------------")
		SendMessage("RightBackSlotInputItem")	
		truegear.play_effect_by_uuid("RightBackSlotInputItem")
	elseif string.find(slotName,"SpinetLeftSlot") then
		SendMessage("--------------------------------")
		SendMessage("LeftBackSlotInputItem")	
		truegear.play_effect_by_uuid("LeftBackSlotInputItem")	
	elseif string.find(slotName,"BeltSlot") then
		SendMessage("--------------------------------")
		SendMessage("LeftHipSlotInputItem")	
		truegear.play_effect_by_uuid("LeftHipSlotInputItem")
	else
		SendMessage("--------------------------------")
		SendMessage("RightHipSlotInputItem")	
		truegear.play_effect_by_uuid("RightHipSlotInputItem")
	end
	-- SendMessage(self:get():GetFullName())
end

function OnActorReleased(self)
	local slotName = self:get():GetFullName()
	if string.find(slotName,"SpinetRightSlot") then
		SendMessage("--------------------------------")
		SendMessage("RightBackSlotOutputItem")	
		truegear.play_effect_by_uuid("RightBackSlotOutputItem")
	elseif string.find(slotName,"SpinetLeftSlot") then
		SendMessage("--------------------------------")
		SendMessage("LeftBackSlotOutputItem")	
		truegear.play_effect_by_uuid("LeftBackSlotOutputItem")	
	elseif string.find(slotName,"BeltSlot") then
		SendMessage("--------------------------------")
		SendMessage("LeftHipSlotOutputItem")
		truegear.play_effect_by_uuid("LeftHipSlotOutputItem")	
	else
		SendMessage("--------------------------------")
		SendMessage("RightHipSlotOutputItem")	
		truegear.play_effect_by_uuid("RightHipSlotOutputItem")
	end
	-- SendMessage(self:get():GetFullName())
end


function EquipArmor(self)
	SendMessage("--------------------------------")
	SendMessage("EquipArmor")
	truegear.play_effect_by_uuid("EquipArmor")
end

function Shot(self)
	if string.find(leftHandItem,"Pistol") then
		SendMessage("--------------------------------")
		SendMessage("LeftHandPistolShoot")
		truegear.play_effect_by_uuid("LeftHandPistolShoot")
	elseif string.find(leftHandItem,"HandCannon") or string.find(leftHandItem,"Duplet") or string.find(leftHandItem,"Sniper") then
		SendMessage("--------------------------------")
		SendMessage("LeftHandShotgunShoot")
		truegear.play_effect_by_uuid("LeftHandShotgunShoot")
	else
		SendMessage("--------------------------------")
		SendMessage("LeftHandRifleShoot")
		truegear.play_effect_by_uuid("LeftHandRifleShoot")
	end
	if string.find(rightHandItem,"Pistol") then
		SendMessage("--------------------------------")
		SendMessage("RightHandPistolShoot")
		truegear.play_effect_by_uuid("RightHandPistolShoot")
	elseif string.find(rightHandItem,"HandCannon") or string.find(rightHandItem,"Duplet") or string.find(rightHandItem,"Sniper") then
		SendMessage("--------------------------------")
		SendMessage("RightHandShotgunShoot")
		truegear.play_effect_by_uuid("RightHandShotgunShoot")
	else
		SendMessage("--------------------------------")
		SendMessage("RightHandRifleShoot")
		truegear.play_effect_by_uuid("RightHandRifleShoot")
	end

	SendMessage(self:get():GetFullName())
end

function PhysicalHit(self,Damage,DamageTypeClass)
	SendMessage("--------------------------------")
	SendMessage("PhysicalHit")
	truegear.play_effect_by_uuid("PoisonDamage")
	currentHP = self:get():GetPropertyValue("CurrentHP")
	totalHP = self:get():GetPropertyValue("HP")
	SendMessage(self:get():GetFullName())
end


function Heal(self)
	SendMessage("--------------------------------")
	SendMessage("Healing")
	truegear.play_effect_by_uuid("Healing")
	currentHP = self:get():GetPropertyValue("CurrentHP")
	totalHP = self:get():GetPropertyValue("HP")
	SendMessage(self:get():GetFullName())
end



function PlayerDeath(self)
	SendMessage("--------------------------------")
	SendMessage("PlayerDeath")
	truegear.play_effect_by_uuid("PlayerDeath")
	leftHandItem = nil
	rightHandItem = nil
	SendMessage(self:get():GetFullName())
end

function HeartBeat()
	if isPause then
		return
	end
	if currentHP / totalHP < 0.5 and totalHP ~= 0 then
		SendMessage("--------------------------------")
		SendMessage("HeartBeat")
		truegear.play_effect_by_uuid("HeartBeat")
	end
end

truegear.init("1039880", "HellSplit:ARENA")

function CheckPlayerSpawned()
	RegisterHook("/Script/Engine.PlayerController:ClientRestart", function()
		if resetHook then
			local ran, errorMsg = pcall(RegisterHooks)
			if ran then
				SendMessage("--------------------------------")
				SendMessage("HeartBeat")
				truegear.play_effect_by_uuid("HeartBeat")
				resetHook = false
			else
				print(errorMsg)
			end
		end		
	end)
end

SendMessage("TrueGear Mod is Loaded");
CheckPlayerSpawned()


LoopAsync(1000, HeartBeat)