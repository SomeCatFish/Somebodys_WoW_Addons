---------------------------------------------------
-- SA_Sync_GetLibs
---------------------------------------------------
local LibDeflate, LibParse, AceComm

if LibStub then
	LibDeflate = LibStub:GetLibrary("LibDeflate")
	LibParse = LibStub:GetLibrary("LibParse")
	AceComm = LibStub("AceComm-3.0")
else
	LibDeflate = require("LibDeflate")
	LibParse = require("LibParse")
	AceComm = require("AceComm-3.0")
end
---------------------------------------------------
-- Объявление переменных
---------------------------------------------------
local channel, channelID, channelName, activeSender, curMembersNumber
local inGroup = false;
local Auras_senders = {};

if StatAurasSyncModule == nil then
	StatAurasSyncModule = {};
	StatAurasSyncModule.customSender = nil;
	StatAurasSyncModule.isGM = false;
	StatAurasSyncModule.blockedSenders = {};
end
---------------------------------------------------
-- Локальные функции
---------------------------------------------------
local function AurasSenderSet()
	local PlyIsLeader = UnitIsGroupLeader("PLAYER");

	for i=1, #Auras_senders do
		if UnitIsConnected(Auras_senders[i]) or #Auras_senders == 1 then
			activeSender = Auras_senders[i];
			return 0;
		end
	end
	if StatAurasSyncModule.customSender ~= nil then							-->	Костыль на случай, если в твоей группе все офф,
		activeSender = StatAurasSyncModule.customSender;					-->	а ауры нужно взять с человека не из группы
		return 0;
	end
	if not PlyIsLeader then
		print("|cffBA6EE6[StatusAura]|r |cffC61E1EВ сети нет источника новых аур! Для того, чтобы включить автообновление аур, введите команду|r |cff6339C3/sasetsender|r");
		return 1;
	end
end

local function AurasSenderSearch()
	local numMembers = GetNumGroupMembers();
	local PlyIsLeader = UnitIsGroupLeader("PLAYER");
	Auras_senders = {};

	if numMembers == 0 then
		inGroup = false;
		if StatAurasSyncModule.customSender ~= nil then
			Auras_senders[1] = StatAurasSyncModule.customSender;
			AurasSenderSet();
			return 0;
		end
		print("|cffBA6EE6[StatusAura]|r |cffC61E1EВы не состоите в группе/рейде! Для того, чтобы включить автообновление аур, введите команду|r |cff6339C3/sasetsender|r");
		return 1;
	end
	if PlyIsLeader then
		if StatAurasSyncModule.customSender ~= nil then
			Auras_senders[1] = StatAurasSyncModule.customSender;
		end
		inGroup = true;
	end

	for i=1, numMembers do
		local name, rank = GetRaidRosterInfo(i);
		if rank == 2 and not PlyIsLeader then
			table.insert(Auras_senders, 1, name);
			inGroup = true;
		elseif rank == 1 then
			table.insert(Auras_senders, name);
		end
	end
	if StatAurasSyncModule.customSender and not PlyIsLeader then
		table.insert(Auras_senders, 2, StatAurasSyncModule.customSender);
	end
	AurasSenderSet();
end
---------------------------------------------------
-- Slash-команды
---------------------------------------------------
SLASH_SAGMTog1 = "/SAGMToggle" or "/sagmtoggle" or "/SAGMTOGGLE" or "/sagmToggle";
SlashCmdList.SAGMTog = function()
	if StatAurasSyncModule.isGM then
		StatAurasSyncModule.isGM = not StatAurasSyncModule.isGM;
		print("|cffBA6EE6[StatusAura]|r Вы отключили режим ведущего. Теперь вы снова получаете информацию об аурах от других игроков при входе в игру или присоединении к группе.");
	elseif not StatAurasSyncModule.isGM then
		StatAurasSyncModule.isGM = not StatAurasSyncModule.isGM;
		print("|cffBA6EE6[StatusAura]|r Вы включили режим ведущего. Теперь вы не будете получать информацию об аурах от других игроков при входе в игру или присоединении к группе.");
	end
end

SLASH_SACustomSender1 = "/SASetSender" or "/sasetsender" or "/SASETSENDER" or "/saSetSender";
SlashCmdList.SACustomSender = function()
	if UnitName("TARGET") == nil and StatAurasSyncModule.customSender == nil then
		print("|cffBA6EE6[StatusAura]|r |cffC61E1EУ вас нет цели!|r");
		return 1;
	elseif UnitName("TARGET") == nil then
		print("|cffBA6EE6[StatusAura]|r Вы перестали запрашивать ауры у персонажа|cffC61E1E", StatAurasSyncModule.customSender);
		StatAurasSyncModule.customSender = nil;
		AurasSenderSearch();
		return 0;
	end

	StatAurasSyncModule.customSender = UnitName("TARGET");
	if inGroup then
		if StatAurasSyncModule.customSender ~= nil then
			Auras_senders[2] = StatAurasSyncModule.customSender;
		else
			table.insert(Auras_senders, 2, StatAurasSyncModule.customSender);
		end
	else
		Auras_senders[1] = StatAurasSyncModule.customSender;
	end
	print("|cffBA6EE6[StatusAura]|r Вы успешно установили персонажа|cffC61E1E", StatAurasSyncModule.customSender, "|rкак источник новых аур.");
	AurasSenderSet();
end

SLASH_SABlockSender1 = "/SABlockSender" or "/sablocksender" or "/SABLOCKSENDER" or "/saBlockSender";
SlashCmdList.SABlockSender = function()
	local PlayerToBlock = UnitName("TARGET");

	if PlayerToBlock == nil then
		print("|cffBA6EE6[StatusAura]|r |cffC61E1EУ вас нет цели!|r");
		return 1;
	end

	for index, name in ipairs(StatAurasSyncModule.blockedSenders) do
		if PlayerToBlock == name then
			table.remove(StatAurasSyncModule.blockedSenders, index);
			print("|cffBA6EE6[StatusAura]|r Вы вернули персонажу|cffC61E1E", PlayerToBlock, "|rвозможность отправлять вам ауры.");
			return 0;
		end
	end

	table.insert(StatAurasSyncModule.blockedSenders, PlayerToBlock);
	print("|cffBA6EE6[StatusAura]|r Вы успешно заблокировали получение аур от персонажа|cffC61E1E", PlayerToBlock, "|r");
end

SLASH_SAGetCustomSender1 = "/SAGetCustomSender" or "/sagetcustomsender" or "/SAGETCUSTOMSENDER" or "/saGetCustomSender";
SlashCmdList.SAGetCustomSender = function()
	if StatAurasSyncModule.customSender then
		print("|cffBA6EE6[StatusAura]|r Ваш пользовательский источник аур — персонаж|cffC61E1E", StatAurasSyncModule.customSender, "|r");
	else
		print("|cffBA6EE6[StatusAura]|r У вас нет пользовательского источника аур.");
	end
end

SLASH_SAGetSender1 = "/SAGetSender" or "/sagetsender" or "/SAGETSENDER" or "/saGetSender";
SlashCmdList.SAGetSender = function()
	if activeSender then
		print("|cffBA6EE6[StatusAura]|r При входе в игру вы получаете ауры от персонажа|cffC61E1E", activeSender, "|r");
	else
		print("|cffBA6EE6[StatusAura]|r Вы не получаете ни от кого ауры при входе в игру.");
	end
end

SLASH_SAGetBlockedSenders1 = "/SAGetBlockedSenders" or "/sagetblockedsenders" or "/SAGETBLOCKEDSENDERS" or "/saGetBlockedSenders";
SlashCmdList.SAGetBlockedSenders = function()
	if #StatAurasSyncModule.blockedSenders == 0 then
		print("|cffBA6EE6[StatusAura]|r Ваш список заблокированных отправителей пуст.  |cffC61E1EДобавьте в него кого-нибудь! :)|r");
		return 0;
	end

	print("|cffBA6EE6[StatusAura]|r |cff9CE1E6Список заблокированных вами отправителей:|r");
	for index, name in ipairs(StatAurasSyncModule.blockedSenders) do
		print("|cffBA6EE6[StatusAura]|r |cff9CE1E6—|r|cffC61E1E", name, "|r");
	end
end
---------------------------------------------------
-- Функции
---------------------------------------------------
function StatAuras.Funcs.ChannelSet()
	channelID = GetChannelName("xtensionxtooltip2");
	if channelID == 0 then
		channel = "RAID";
		channelID = nil;
	else
		channel = "CHANNEL";
		channelName = "xtensionxtooltip2";
	end
end

function StatAuras.Funcs.InfoQuery()
	AceComm:SendCommMessage("SA_CharOnEnterQ", "Auras get query.", "WHISPER", activeSender, "ALERT");
end

function StatAuras.Funcs.SendAurasOnSet(unit_type)
	local database_entity_to_send;
	local guid;
	if unit_type == "ply" then
		guid = UnitGUID("player");
	else
		guid = UnitGUID("target");
	end
	if guid == nil then
		return 1;													--> Нет цели
	end
	if (GetPlayerInfoByGUID(guid)) then
		database_entity_to_send = {guid, "PLY", StatAurasDatabase.PlayersAuras[guid]};
	else
		database_entity_to_send = {guid, "NPC", StatAurasDatabase.NPCAuras[guid]};
	end

	local SoR = LibParse:JSONEncode(database_entity_to_send);				-->	SoR = Send or Receive
	SoR = LibDeflate:CompressDeflate(SoR);
	SoR = LibDeflate:EncodeForWoWAddonChannel(SoR);

	AceComm:SendCommMessage("SA_SendOnSetQ", SoR, channel, channelID, "ALERT");
end

function StatAuras.Funcs.QueryHandler(prefix, message, distribution, sender)
	if ( prefix == "SA_CharOnEnterQ" ) then
		for index, name in ipairs(StatAurasSyncModule.blockedSenders) do	--> Проверка, не заблокирован ли отправляющий
			if sender == name then
				return 1;
			end
		end

		local SoR = LibParse:JSONEncode(StatAurasDatabase);			-->	SoR = Send or Receive
		SoR = LibDeflate:CompressDeflate(SoR);
		SoR = LibDeflate:EncodeForWoWAddonChannel(SoR);

		AceComm:SendCommMessage("SA_CharOnEnterR", SoR, "WHISPER", sender, "BULK");
	--=====================================================================================--
	elseif ( prefix == "SA_CharOnEnterR" ) then
		local SoR = LibDeflate:DecodeForWoWAddonChannel(message);	-->	SoR = Send or Receive
		SoR = LibDeflate:DecompressDeflate(SoR);
		SoR = LibParse:JSONDecode(SoR);

		StatAurasDatabase = SoR;
		StatAuras.Funcs.DisplayAurasUpdate("player", SA_PlayerAurasAnchor);
		StatAuras.Funcs.DisplayAurasUpdate("target", SA_TargetAurasAnchor);
	--=====================================================================================--
	elseif ( prefix == "SA_SendOnSetQ" ) and ( sender ~= UnitName("PLAYER") ) then
		for index, name in ipairs(StatAurasSyncModule.blockedSenders) do	--> Проверка, не заблокирован ли отправляющий
			if sender == name then
				return 1;
			end
		end

		local SoR = LibDeflate:DecodeForWoWAddonChannel(message);	-->	SoR = Send or Receive
		SoR = LibDeflate:DecompressDeflate(SoR);
		SoR = LibParse:JSONDecode(SoR);

		local guid = SoR[1];
		local UnitType = SoR[2];
		if UnitType == "PLY" then
			StatAurasDatabase.PlayersAuras[guid] = SoR[3];
		elseif UnitType == "NPC" then
			StatAurasDatabase.NPCAuras[guid] = SoR[3];
		end

		StatAuras.Funcs.DisplayAurasUpdate("player", SA_PlayerAurasAnchor);
		StatAuras.Funcs.DisplayAurasUpdate("target", SA_TargetAurasAnchor);
	end
end
---------------------------------------------------
-- Подключение регистрации ивентов
---------------------------------------------------
local SA_Sync_Frame = CreateFrame("FRAME", "SA_Sync_Frame")	-- Создание фрейма для регистрации событий
local StatAuras_Funcs = StatAuras.Funcs;					-- Создание "указателя" на таблицу с функциями (чтобы eventHandler знал, откуда их брать)

local function eventHandler(self, event, arg1, ...)
	--======================================================================
	--	Включение регистрации сообщений между клиентами после загрузки UI
	--======================================================================
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		AceComm:RegisterComm("SA_CharOnEnterQ", StatAuras_Funcs.QueryHandler);
		AceComm:RegisterComm("SA_CharOnEnterR", StatAuras_Funcs.QueryHandler);
		AceComm:RegisterComm("SA_SendOnSetQ", StatAuras_Funcs.QueryHandler);
	--======================================================================
	--		Подключение каналов для передачи аур + проверка в рейде ли
	--
	--	Почти то же, что и выше, НО регистрация этого события нужна
	--	ПОТОМУ что только после него клиент получает имена членов рейда.
	--======================================================================
	elseif ( event == "UPDATE_INSTANCE_INFO" ) then
		SA_Sync_Frame:RegisterEvent("CHANNEL_UI_UPDATE");
		StatAuras_Funcs.ChannelSet();
		curMembersNumber = GetNumGroupMembers();
		AurasSenderSearch();
		if not StatAurasSyncModule.isGM and not UnitIsGroupLeader("PLAYER") then
			StatAuras_Funcs.InfoQuery();
		end
	--======================================================================
	--				Проверка того, не пропал ли xtensionxtooltip2
	--						  после изменения каналов
	--======================================================================
	elseif ( event == "CHANNEL_UI_UPDATE" ) then
		StatAuras_Funcs.ChannelSet();
	--======================================================================
	--	   Проверка того, нужно ли перевешивать "крюк" автообновления аур 
	--		   на другого игрока, если кто-то зашёл/вышел в игру/рейд
	--				+ запрос на ауры при присоединении к рейду
	--======================================================================
	elseif ( event == "GROUP_ROSTER_UPDATE" ) then
		if ( curMembersNumber == nil or 0 ) and ( curMembersNumber ~= GetNumGroupMembers() ) then	-- Присоединение к рейду
			curMembersNumber = GetNumGroupMembers();
			AurasSenderSearch();
			if not StatAurasSyncModule.isGM and not UnitIsGroupLeader("PLAYER") then
				StatAuras_Funcs.InfoQuery();
			end
			return 0;

		elseif curMembersNumber ~= GetNumGroupMembers() then	-- Свидетельствует о том, что игрок зашёл/вышел в/из рейд(а) ИЛИ другой человек вышел/зашёл в/из рейд(а)
			curMembersNumber = GetNumGroupMembers();
			AurasSenderSet();
			return 0;
		end
	--======================================================================
	--	   Добавление нового лидера/помощника рейда в список целей для 
	--							автообновления
	--======================================================================
	elseif ( event == "PLAYER_ROLES_ASSIGNED" ) and ( curMembersNumber > 0 ) then
		AurasSenderSearch();
	end
end

SA_Sync_Frame:RegisterEvent("PLAYER_ENTERING_WORLD");
SA_Sync_Frame:RegisterEvent("CHAT_MSG_ADDON");
SA_Sync_Frame:RegisterEvent("UPDATE_INSTANCE_INFO");	-- Использовать для AurasSenderSearch(), ChannelSet() и InfoQuery() вместо PLY_ENTERING_WORLD
SA_Sync_Frame:RegisterEvent("GROUP_ROSTER_UPDATE");		-- Кто-то выходит/заходит/присоединяется к группе ...
SA_Sync_Frame:RegisterEvent("PLAYER_ROLES_ASSIGNED");	-- Запускается при смене лидера/выдаче ассистов
SA_Sync_Frame:SetScript("OnEvent", eventHandler);
---------------------------------------------------