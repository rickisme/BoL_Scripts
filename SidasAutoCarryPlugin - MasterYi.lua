local QReady, EReady, RReady = nil, nil, nil
local RangeQ, RangeMeele, RangeJump = 600, 150, 150

function PluginOnLoad()
	AutoCarry.PluginMenu:addParam("autoR", "Auto R in Combo", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("ks", "KS with Q", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("dqR", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("qHarass", "Minion Q Harass", SCRIPT_PARAM_ONOFF, true)

	AutoCarry.SkillsCrosshair.range = RangeQ
end

function PluginOnTick()
	CDHandler()
	if AutoCarry.PluginMenu.ks then KS() end
	if AutoCarry.MainMenu.AutoCarry then Combo() end
	if AutoCarry.MainMenu.MixedMode and AutoCarry.PluginMenu.qHarass then MinionQHero() end
end

function PluginOnDraw()
	if not myHero.dead and AutoCarry.PluginMenu.dqR then
		DrawCircle(myHero.x, myHero.y, myHero.z, RangeQ, 0x00FFFF)
	end
end

function CDHandler()
	QReady = (myHero:CanUseSpell(_Q) == READY)
	EReady = (myHero:CanUseSpell(_E) == READY)
	RReady = (myHero:CanUseSpell(_R) == READY)
end

function KS()
	for _, enemy in pairs(AutoCarry.EnemyTable) do
		if ValidTarget(enemy, RangeQ) and getDmg("Q", enemy, myHero) >= enemy.health then
			CastSpell(_Q, enemy)
		end
	end
end

function Combo()
	local Target = AutoCarry.GetAttackTarget()

	if ValidTarget(Target) then
		local Distance = GetDistance(Target)

		if RReady and Distance <= RangeMeele and not TargetHaveBuff("Highlander", myHero) and AutoCarry.PluginMenu.autoR then CastSpell(_R) end
		if EReady and ((QReady and Distance <= RangeQ) or (Distance <= RangeMeele)) then CastSpell(_E) end
		if QReady and Distance <= RangeQ then CastSpell(_Q, Target) end
	end
end

function MinionQHero()
	if not QReady then return end

	local Minions = {}
	local NearestMinion = nil
	local MinionCount = 0
 
	for index, minion in pairs(AutoCarry.EnemyMinions().objects) do
		if ValidTarget(minion) then
			if GetDistance(minion) <= 600 then
				for _, enemy in pairs(AutoCarry.EnemyTable) do
					if GetDistance(minion, enemy) <= RangeJump then
						table.insert(Minions, minion)
						MinionCount = MinionCount + 1
					end
				end
			end
		end
	end
 
	if MinionCount == 0 then return end

	for _, jumpTarget in pairs(Minions) do
		if NearestMinion and NearestMinion.valid and jumpTarget and jumpTarget.valid then
			if GetDistance(jumpTarget) < GetDistance(NearestMinion) then
				NearestMinion = jumpTarget
			end
		else
			NearestMinion = jumpTarget
		end
	end
 
	if ValidTarget(NearestMinion) and MinionCount <= 3 and QReady then CastSpell(_Q, NearestMinion) end
end