---------------------------------------------------
-- SA_Sync_GetLibs
---------------------------------------------------
local SomeBodysUtils;

if LibStub then
	SomeBodysUtils = LibStub:GetLibrary("SomeBodysUtils");
else
	SomeBodysUtils = require("SomeBodysUtils");
end
---------------------------------------------------
-- SA_Variables
---------------------------------------------------
StatAuras = {};
StatAuras.Vars = {};
StatAuras.Funcs = {};
if StatAurasDatabase == nil then
	StatAurasDatabase = {};
	StatAurasDatabase.PlayersAuras = {};
	StatAurasDatabase.NPCAuras = {};
	StatAurasDatabase.AurasPool = {
		[1] = {1, "|cff942727Очки Здоровья|r", "Показатель жизненной силы персонажа.", "Interface\\ICONS\\Spell_Shadow_LifeDrain", "Player_Name", true, ""},
		[2] = {2, "|cff277E94Очки Энергии|r", "Показатель энергии персонажа.", "Interface\\ICONS\\INV_Elemental_Mote_Mana", "Player_Name", true, ""},
		[3] = {3, "Очки Брони", "", "Interface\\ICONS\\INV_Shield_06", "Player_Name", true, ""},
		[4] = {4, "Очки Барьера", "", "Interface\\ICONS\\Spell_Shadow_AntiMagicShell", "Player_Name", true, ""},
		[5] = {5, "Очки Атаки", "", "Interface\\ICONS\\INV_Sword_04", "Player_Name", true, ""}
	};
end
if StatAurasDatabase.AurasPool == nil or StatAurasDatabase.AurasPool == {} then
	StatAurasDatabase.AurasPool = {
		[1] = {1, "|cff942727Очки Здоровья|r", "Показатель жизненной силы персонажа.", "Interface\\ICONS\\Spell_Shadow_LifeDrain", "Player_Name", true, ""},
		[2] = {2, "|cff277E94Очки Энергии|r", "Показатель энергии персонажа.", "Interface\\ICONS\\INV_Elemental_Mote_Mana", "Player_Name", true, ""},
		[3] = {3, "Очки Брони", "", "Interface\\ICONS\\INV_Shield_06", "Player_Name", true, ""},
		[4] = {4, "Очки Барьера", "", "Interface\\ICONS\\Spell_Shadow_AntiMagicShell", "Player_Name", true, ""},
		[5] = {5, "Очки Атаки", "", "Interface\\ICONS\\INV_Sword_04", "Player_Name", true, ""}
	};
end
---------------------------------------------------
-- Slash-команды
---------------------------------------------------
SLASH_SADEF1 = "/sadef" or "/SADEF" or "/saDef";
SlashCmdList.SADEF = function()
	local menu = Def_SA_MainMenu;
	menu:SetShown(not menu:IsShown());
end
SLASH_SADBCLEAR1 = "/sanpcdbclear" or "/SANPCDBCLEAR" or "/sanpdbclear" or "/SANPDBCLEAR" or "/saNPCDBClear";
SlashCmdList.SADBCLEAR = function()
	StatAurasDatabase.NPCAuras = {};
	StatAuras.Funcs.DisplayAurasUpdate("target", SA_TargetAurasAnchor)
	print("|cffBA6EE6[StatusAura]|r |cffC61E1EБаза данных аур НПЦ успешно очищена!|r");
end
SLASH_SACUS1 = "/sacustom" or "/SACUSTOM";
SlashCmdList.SACUS = function()
	local menu = Cus_SA_MainMenu;
	menu:SetShown(not menu:IsShown());
end
SLASH_SAHELP1 = "/sahelp" or "/SAHELP" or "/SAHelp" or "/SAhelp" or "/saHelp";
SlashCmdList.SAHELP = function()
	print("|cffBA6EE6[StatusAura]|r |cffFFB266Доступные команды:|r");
	print("|cff9CE1E61.|r |cff9CE1E6/saDef|r |cffFFB266- открыть меню со стандартными аурами.|r");
	print("|cff9CE1E62.|r |cff9CE1E6/saNPCDBClear|r |cffFFB266- очистить базу данных аур НПЦ.|r");
	if StatAurasSyncModule then
		print();
		print("|cffBA6EE6[StatusAura |cff9CE1E6Sync_Module|r|cff6339C3]|r |cffFFB266Доступные команды:|r");
		print("|cff9CE1E61.|r |cff9CE1E6/sagmToggle|r |cffFFB266- включить/отключить |cff9CE1E6режим ведущего|r|cffFFB266.|r");
		print("|cff9CE1E62.|r |cff9CE1E6/saModeSwitch|r |cffFFB266- переключить режим получения аур на |cff606060чёрный|r/|cffFFFFFFбелый|r список.|r");
		print("|cff9CE1E63.|r |cff9CE1E6/saAWLtoggle|r |cffFFB266- включить/отключить |cff9CE1E6автоматическое добавление|r избранного отправителя аур, лидера рейда и его помощников в |cffFFFFFFбелый|r список|cffFFB266.|r");
		print("|cff9CE1E64.|r |cff9CE1E6/saSetSender|r |cffFFB266- указать персонажа-цель как предпочтительный источник новых аур.|r");
		print("|cff9CE1E65.|r |cff9CE1E6/saBlockSender|r |cff9CE1E6- |cffC61E1Eзаблокировать|cffFFB266 получение новых/обновление старых аур от персонажа-цели.|r");
		print("|cff9CE1E66.|r |cff9CE1E6/saWhitelistSender|r |cff9CE1E6- |cff1EC724разрешить|cffFFB266 получение новых/обновление старых аур от персонажа-цели.|r");
		print("|cff9CE1E67.|r |cff9CE1E6/saGetSender|r |cffFFB266- выписать персонажа, от которого вы получаете ауры при входе в игру.|r");
		print("|cff9CE1E68.|r |cff9CE1E6/saGetPriority|r |cffFFB266- выписать список персонажей-отправителей аур в порядке приоритета.|r");
		print("|cff9CE1E69.|r |cff9CE1E6/saGetCustomSender|r |cffFFB266- выписать персонажа, который является предпочтительным для получения аур при входе в игру.|r");
		print("|cff9CE1E610.|r |cff9CE1E6/saGetBlockedSenders|r |cffFFB266- выписать персонажей, получение аур от которых вы |cffC61E1Eзаблокировали|r.|r");
		print("|cff9CE1E611.|r |cff9CE1E6/saGetWhitelistedSenders|r |cffFFB266- выписать персонажей, получение аур от которых вы |cff1EC724разрешили|r.|r");
		print("|cff9CE1E612.|r |cff9CE1E6/saClearBlacklist|r |cffFFB266- очистить |cff606060чёрный список|r отправителей.|r");
		print("|cff9CE1E613.|r |cff9CE1E6/saClearWhitelist|r |cffFFB266- очистить |cffFFFFFFбелый список|r отправителей.|r");
	end
end
---------------------------------------------------
-- Функции
---------------------------------------------------
StatAuras.Vars.CurAuraNum_Std = 0;
StatAuras.Vars.CurAuraNum_Cus = 0;

function StatAuras.Funcs.SwitchFrame(targetFrame)
	if TargetFrameBuff1:IsVisible() then
		targetFrame:Hide();
	else
		targetFrame:Show();
	end
end

function StatAuras.Funcs.typeRadio(targetButton)
	HP_Radio:SetChecked(false);
	MP_Radio:SetChecked(false);
	AR_Radio:SetChecked(false);
	BAR_Radio:SetChecked(false);
	ATK_Radio:SetChecked(false);
	targetButton:SetChecked(true);
end

function StatAuras.Funcs.StdAuraType(n)
	StatAuras.Vars.CurAuraNum_Std = n;
end

function StatAuras.Funcs.CusAuraType(n)
	StatAuras.Vars.CurAuraNum_Cus = n;
end

function StatAuras.Funcs.DeleteAura(guid, auranum, db)
	table.remove(db[guid], auranum);
	if #db[guid] == 0 then
		SomeBodysUtils:removebykey(db, guid)
	end
	return db;
end

function StatAuras.Funcs.UnstackableCheck(auraTable, stacks, operation)
	if auraTable[6] then							-- || If aura IS, in fact, stackable
		return stacks;
	end

	if (operation == "set" or operation == "change_nil") and stacks > 0 then
		stacks = 1;
		auraTable[7] = stacks;
		return stacks;
	end

	if operation == "change" and stacks >= 0 then
		stacks = 0;
		auraTable[7] = stacks;
		return stacks;
	end

	return stacks;									-- || Just for safety, in case stacks value will SOMEHOW be negative
end

function StatAuras.Funcs.SetAura(aura, guid, stacks, db)
	local OwnerName = UnitName("player");
	local temp_aura_table = {};
	temp_aura_table = SomeBodysUtils:AuraTableCopy(aura);
	stacks = tonumber(stacks);
	temp_aura_table[7] = stacks;
	stacks = StatAuras.Funcs.UnstackableCheck(temp_aura_table, stacks, "set");

	for db_guid, guid_auras in pairs(db) do
		if guid == db_guid then
			for i=1, #guid_auras do						-- || If target_guid exists, is aura
			  if temp_aura_table[1] == guid_auras[i][1] then
				if stacks > 0 then
					guid_auras[i][5] = OwnerName;		-- Смена "владельца" навешенной ауры
					guid_auras[i][7] = stacks;			-- Стаки
					return db;
				else
					return StatAuras.Funcs.DeleteAura(db_guid, i, db);
				end
			  end
			end
			if stacks > 0 then							-- || If target_guid exists, but no aura
				table.insert(db[db_guid], temp_aura_table);
			  	local table_num = #db[db_guid];
			  	db[db_guid][table_num][5] = OwnerName;	-- Смена "владельца" навешенной ауры
			end
			return db;
		end
	end
	if stacks > 0 then									-- || If target_guid does not exist in DB
		db[guid] = {temp_aura_table};
		local table_num = #db[guid];
		db[guid][table_num][5] = OwnerName;				-- Смена "владельца" навешенной ауры
	end
	return db;
end

function StatAuras.Funcs.ChangeAuraStacks(aura, guid, stacks, db, math_symbol)
	local OwnerName = UnitName("player");
	local temp_aura_table = {};
	stacks = tonumber(stacks) * math_symbol;
	temp_aura_table = SomeBodysUtils:AuraTableCopy(aura);
	temp_aura_table[7] = stacks;

	for db_guid, guid_auras in pairs(db) do
		if guid == db_guid then
			for i=1, #guid_auras do												-- || If target_guid exists, is aura
			  if temp_aura_table[1] == guid_auras[i][1] then
				if (guid_auras[i][7] + stacks) > 0 then
					stacks = StatAuras.Funcs.UnstackableCheck(temp_aura_table, stacks, "change");
					guid_auras[i][5] = OwnerName;								-- Смена "владельца" навешенной ауры
					guid_auras[i][7] = (guid_auras[i][7] + stacks);				-- Стаки
					return db;
				else
					return StatAuras.Funcs.DeleteAura(db_guid, i, db);
				end
			  end
			end
			if stacks > 0 then													-- || If target_guid exists, but no aura
				StatAuras.Funcs.UnstackableCheck(temp_aura_table, stacks, "change_nil");
				table.insert(db[db_guid], temp_aura_table);
			  	local table_num = #guid_auras;
			  	guid_auras[table_num][5] = OwnerName;							-- Смена "владельца" навешенной ауры
			end
			return db;
		end
	end
	if stacks > 0 then															-- || If target_guid does not exist in DB
		StatAuras.Funcs.UnstackableCheck(temp_aura_table, stacks, "change_nil");
		db[guid] = {temp_aura_table};
		local table_num = #db[guid];
		db[guid][table_num][5] = OwnerName;										-- Смена "владельца" навешенной ауры
	end
	return db;
end

function StatAuras.Funcs.RemoveAura(auranum, unit_type)
	local auraID = StatAurasDatabase.AurasPool[auranum][1];
	local guid;
	if unit_type == "ply" then
		guid = UnitGUID("player");
	else
		guid = UnitGUID("target");
	end
	if guid == nil then	
		print("|cffBA6EE6[StatusAura]|r |cffC61E1EУ вас нет цели!|r");
		return 1;
	end
	local aura_database;
	if (GetPlayerInfoByGUID(guid)) then
		aura_database = StatAurasDatabase.PlayersAuras;
	else
		aura_database = StatAurasDatabase.NPCAuras;
	end
	----------------------------------------------------------------------
	for db_guid, guid_auras in pairs(aura_database) do
		if guid == db_guid then
			for i=1, #guid_auras do
			  if auraID == guid_auras[i][1] then
				aura_database = StatAuras.Funcs.DeleteAura(db_guid, i, aura_database);
				if (GetPlayerInfoByGUID(guid)) then
					StatAurasDatabase.PlayersAuras = aura_database;
				else
					StatAurasDatabase.NPCAuras = aura_database;
				end
				return 0;
			  end
			end
			print("|cffBA6EE6[StatusAura]|r |cffC61E1EУ цели нет выбранной ауры!|r");
			return 2;
		end
	end
	print("|cffBA6EE6[StatusAura]|r |cffC61E1EУ цели нет активных аур!|r");
	return 3;
end

function StatAuras.Funcs.ModifyAura(stacks, operation, auranum, unit_type)
	local aura = StatAurasDatabase.AurasPool[auranum];
	local guid;
	if unit_type == "ply" then
		guid = UnitGUID("player");
	else
		guid = UnitGUID("target");
	end
	if guid == nil then	
		print("|cffBA6EE6[StatusAura]|r |cffC61E1EУ вас нет цели!|r");
		return 1;
	end
	if operation == "set" then
		if (GetPlayerInfoByGUID(guid)) then
			StatAurasDatabase.PlayersAuras = StatAuras.Funcs.SetAura(aura, guid, stacks, StatAurasDatabase.PlayersAuras);
		else
			StatAurasDatabase.NPCAuras = StatAuras.Funcs.SetAura(aura, guid, stacks, StatAurasDatabase.NPCAuras);
		end
	elseif operation == "increase" then
		if (GetPlayerInfoByGUID(guid)) then
			StatAurasDatabase.PlayersAuras = StatAuras.Funcs.ChangeAuraStacks(aura, guid, stacks, StatAurasDatabase.PlayersAuras, 1);
		else
			StatAurasDatabase.NPCAuras = StatAuras.Funcs.ChangeAuraStacks(aura, guid, stacks, StatAurasDatabase.NPCAuras, 1);
		end
	elseif operation == "decrease" then
		if (GetPlayerInfoByGUID(guid)) then
			StatAurasDatabase.PlayersAuras = StatAuras.Funcs.ChangeAuraStacks(aura, guid, stacks, StatAurasDatabase.PlayersAuras, -1);
		else
			StatAurasDatabase.NPCAuras = StatAuras.Funcs.ChangeAuraStacks(aura, guid, stacks, StatAurasDatabase.NPCAuras, -1);
		end
	end
	return 0;
end

function StatAuras.Funcs.TargetAurasAnchorUpdate()
	local anchor_yOffset = (32 - (SA_TargetAura1:GetHeight() + 6) * (TargetFrame.auraRows));
	SA_TargetAurasAnchor:ClearAllPoints();
	SA_TargetAurasAnchor:SetPoint("TOPLEFT", "TargetFrame", "BOTTOMLEFT", 5, anchor_yOffset);
end

function StatAuras.Funcs.PlayerAurasAnchorUpdate()
	local PlayerAurasAmount = 0;
	AuraUtil.ForEachAura("player", "HELPFUL", nil, function()
		PlayerAurasAmount = PlayerAurasAmount + 1;
	end);

	local PlayerAurasRows = (PlayerAurasAmount - mod(PlayerAurasAmount, 8)) / 8;
	if (math.fmod(PlayerAurasAmount, 8) > 0) then
		PlayerAurasRows = PlayerAurasRows + 1;
	end
	local anchor_yOffset = (0 - (SA_PlayerAura1:GetHeight() + 15) * (PlayerAurasRows));
	SA_PlayerAurasAnchor:ClearAllPoints();
	SA_PlayerAurasAnchor:SetPoint("TOPRIGHT", "BuffFrame", "TOPRIGHT", 0, anchor_yOffset);
end

function StatAuras.Funcs.DisplayAurasUpdate(unitID, AurasAnchor)
	if UnitGUID(unitID) == nil then
		AurasAnchor:Hide();
		return 0;
	end

	local guid = UnitGUID(unitID);
	local aura_database = {};
	if (GetPlayerInfoByGUID(guid)) then
		aura_database = StatAurasDatabase.PlayersAuras;
	else
		aura_database = StatAurasDatabase.NPCAuras;
	end

	local tooltip_anchor = "ANCHOR_BOTTOMLEFT";											-- Tooltip anchoring
	local tooltip_xoff = 0;
	local tooltip_yoff = 0;
	if unitID == "target" then
		tooltip_anchor = "ANCHOR_BOTTOMRIGHT";
		tooltip_xoff = 15;
		tooltip_yoff = -25;
	end

	for db_guid, guid_auras in pairs(aura_database) do
		if guid == db_guid then
			local active_auras_num = #guid_auras;
			local aura_containers = { AurasAnchor:GetChildren() };
			for i=1, active_auras_num do												-- Показывает активные ауры.
				local aura_element_containers = { aura_containers[i]:GetChildren() };
				local aura_element = { aura_element_containers[1]:GetRegions() };		-- [1] стаки; [2] иконка
				aura_element = aura_element[1];
				if guid_auras[i][7] == 1 then
					aura_element:SetText("");
				else
					aura_element:SetText(tostring(guid_auras[i][7]));
				end
				
				aura_element = { aura_element_containers[2]:GetRegions() };
				aura_element = aura_element[1];
				aura_element:SetTexture(guid_auras[i][4]);
				
				aura_containers[i]:SetScript("OnEnter", function()						--	Установка скриптов для тултипов
					GameTooltip:SetOwner(aura_containers[i], tooltip_anchor, tooltip_xoff, tooltip_yoff)
					GameTooltip:AddLine(guid_auras[i][2])
					GameTooltip:AddLine(guid_auras[i][3], 1, 1, 1, true)
					GameTooltip:AddDoubleLine("AuraID:", guid_auras[i][1], nil, nil, nil, 0.71, 1, 1)
					GameTooltip:AddDoubleLine("Владелец:", guid_auras[i][5], nil, nil, nil, 0.71, 1, 1)
					GameTooltip:Show()
				end)
				aura_containers[i]:SetScript("OnLeave", function()
					GameTooltip:ClearLines()
					GameTooltip:Hide()
				end)
				aura_containers[i]:Show();

			end
			for n = active_auras_num+1, #aura_containers do								-- Скрывает ненужные ауры.
				aura_containers[n]:Hide();
			end
			AurasAnchor:Show();
			return 0;
		end
	end
	AurasAnchor:Hide();
	return 0;
end

function StatAuras.Funcs.DisplayAuraCrementByOne(auranum, button, unitID)	-- auranum - индекс ауры в таблице аур цели
	local guid = UnitGUID(unitID);											-- Если ничего не изменено и не сломано, то оно всегда
	local db;																-- соответствует порядочному номеру иконки ауры.
	if (GetPlayerInfoByGUID(guid)) then
		db = StatAurasDatabase.PlayersAuras;
	else
		db = StatAurasDatabase.NPCAuras;
	end
	local auras_pointer;
	for db_guid, guid_auras in pairs(db) do
		if guid == db_guid then
			auras_pointer = guid_auras;
		end
	end
	local aura = auras_pointer[auranum];

	if button == "LeftButton" then
		db = StatAuras.Funcs.ChangeAuraStacks(aura, guid, 1, db, 1);
	elseif button == "RightButton" then
		db = StatAuras.Funcs.ChangeAuraStacks(aura, guid, 1, db, -1);
	end

	if UnitGUID("target") == UnitGUID("player") then
		StatAuras.Funcs.DisplayAurasUpdate(unitID, SA_PlayerAurasAnchor);
		StatAuras.Funcs.DisplayAurasUpdate(unitID, SA_TargetAurasAnchor);
	elseif unitID == "player" then
		StatAuras.Funcs.DisplayAurasUpdate(unitID, SA_PlayerAurasAnchor);
	else
		StatAuras.Funcs.DisplayAurasUpdate(unitID, SA_TargetAurasAnchor);
	end
	return 0;
end

function StatAuras.Funcs.UI_Scaling()
	local UI_scale = UIParent:GetEffectiveScale();
	SA_TargetAurasAnchor:SetScale(UI_scale);
	SA_PlayerAurasAnchor:SetScale(UI_scale);
	Def_SA_MainMenu:SetScale(UI_scale);
	return 0;
end

function StatAuras.Funcs.AurasPoolSearch(auraID)
	for aura_index, aura in pairs(StatAurasDatabase.AurasPool) do
		if aura[1] == auraID then
			return aura_index;
		end
	end
	return nil;
end
---------------------------------------------------