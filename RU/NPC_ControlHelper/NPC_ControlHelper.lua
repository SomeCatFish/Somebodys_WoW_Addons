---------------------------------------------------
-- NPCCH_Namespace
---------------------------------------------------
NPC_ControlHelper = {};
NPC_ControlHelper.Vars = {};
NPC_ControlHelper.Vars.LeadGUID = nil;
NPC_ControlHelper.Vars.FormationMovement = false;
NPC_ControlHelper.Funcs = {};

if NPC_ControlHelper_Config == nil then
	NPC_ControlHelper_Config = {};
	NPC_ControlHelper_Config.PrintInfoEnabled = true;
end
---------------------------------------------------
-- Slash-команды
---------------------------------------------------
SLASH_NPCCHMEN1 = "/NPCcontrolhelper" or "/NPCCONTROLHELPER" or "/npccontrolhelper" or "/NPCControlHelper" or "/npcControlHelper";
SlashCmdList.NPCCHMEN = function()
	local menu = NPC_ControlHelper_MainMenu;
	menu:SetShown(not menu:IsShown());
end

SLASH_NPCCHINFTOG1 = "/NPCCHInfoToggle" or "/NPCCHINFOTOGGLE" or "/NPCCHinfotoggle" or "/npcchinfotoggle" or "/npcchInfoToggle";
SlashCmdList.NPCCHINFTOG = function()
	NPC_ControlHelper_Config.PrintInfoEnabled = not NPC_ControlHelper_Config.PrintInfoEnabled;
	if not NPC_ControlHelper_Config.PrintInfoEnabled then
		print("|cffBA6EE6[NPC Control Helper]|r |cffFFFF00Вы отключили сообщения от АддОна.|r");
	else
		print("|cffBA6EE6[NPC Control Helper]|r |cffFFFF00Вы включили сообщения от АддОна.|r");
	end
end
---------------------------------------------------
-- Функции изменения размера интерфейса
---------------------------------------------------
local function ResizingStart(self, button)
	if button == "LeftButton" then
		local parent = self:GetParent()
		self.isScaling = true
		parent:StartSizing("BOTTOMRIGHT")
	end
end

local function ResizingEnd(self, button)
	if button == "LeftButton" then
		local parent = self:GetParent()
		self.isScaling = false
		parent:StopMovingOrSizing()
	end
end

-- local function FontStringsSizing(frame)
-- 	local n = frame:GetWidth()
-- 	frame:SetHeight(n)
-- 	n = n / size.x
-- 	local childrens = { frame.Inset:GetRegions() }
-- 	for _, child in ipairs(childrens) do
-- 		child:SetScale(n)
-- 	end
-- 	for _, child in pairs(framesToResizeWithMainFrame) do
-- 		child:SetScale(n)
-- 	end
-- 	return n;
-- end

-- Sizing funcs hooking
ResizeBtn:SetScript("OnMouseDown", ResizingStart);
ResizeBtn:SetScript("OnMouseUp", ResizingEnd);
-- NPC_ControlHelper_MainMenu:SetScript("OnSizeChanged", FontStringsSizing)
---------------------------------------------------
-- Функции
---------------------------------------------------
local function command(text)
    SendChatMessage("."..text, "GUILD");
end

local function printInfo(msg)
	if NPC_ControlHelper_Config.PrintInfoEnabled then
		print(msg);
	end
end

local function EpsilonTagMSG_Filter(self, event, msg, ...)
	if msg:find("[Epsilon] Commands under the (.-) category will (.+)") then
		return true;
	end
end

local function StartChatFiltering(filterfunc)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", filterfunc);
end

local function StopChatFiltering(filterfunc)
    ChatFrame_RemoveMessageEventFilter("CHAT_MSG_SYSTEM", filterfunc);
end

function NPC_ControlHelper.Funcs.NPC_GUIDBox_OnTextChanged(self)
	local helpstr = _G[self:GetName() .. "HelpString"];
	if self:GetText() == "" then
		helpstr:Show();
	else
		helpstr:Hide();
	end
end

function NPC_ControlHelper.Funcs.TabBtnHandler(self)
	PanelTemplates_SetTab(self:GetParent(), self:GetID());

	local numTabs = NPC_ControlHelper_MainMenu.numTabs;
	local selTabID = NPC_ControlHelper_MainMenu.selectedTab;
	local activePage = _G["NPC_ControlHelper_Page" .. selTabID];

	-- Сокрытие всех вкладок и открытие "активной"
	for i=1, numTabs do
		local otherPage = _G["NPC_ControlHelper_Page" .. i];
		otherPage:SetShown(activePage == otherPage);
	end
end

function NPC_ControlHelper.Funcs.UI_Scaling()
	local UI_scale = UIParent:GetEffectiveScale();
	NPC_ControlHelper_MainMenu:SetScale(UI_scale);
	return 0;
end
---------------------------------------------------
-- Функции главной страницы
---------------------------------------------------
local function NPCMiscInfo_Filter(self, event, msg, ...)
	if msg:find("InhabitType.+") or msg:find("Position.+") or msg:find("AIName.+") or msg:find("Has Waypoint.+") or msg:find("Phase Forged.+") or msg:find("Built by.+") then
		return true;
	end
end

local function NPCTransmogInfo_Filter(self, event, msg, ...)
	if msg:find("Helmet.+") or msg:find("Shoulders.+") or msg:find("Chest.+") or msg:find("Shirt.+") or msg:find("Wrists.+") or msg:find("Gloves.+") or msg:find("Belt.+") or msg:find("Legs.+") or msg:find("Boots.+") or msg:find("Tabard.+") or msg:find("Cape.+") then
		return true;
	end
end

function NPC_ControlHelper.Funcs.NPC_Search(NPC_name)
	command("ph f np l " .. tostring(NPC_name));
end

function NPC_ControlHelper.Funcs.NPC_Delete(NPC_GUID)
	command("np del " .. tostring(NPC_GUID));
end

function NPC_ControlHelper.Funcs.NPC_SecurePos()
	StartChatFiltering(EpsilonTagMSG_Filter);
	command("np move upwards 0.001");
	C_Timer.After(0.5, function() StopChatFiltering(EpsilonTagMSG_Filter) end);
end

function NPC_ControlHelper.Funcs.NPC_Info()
	StartChatFiltering(NPCMiscInfo_Filter);
	StartChatFiltering(NPCTransmogInfo_Filter);
	command("np info");
	C_Timer.After(0.5, function() StopChatFiltering(NPCMiscInfo_Filter) end);
	C_Timer.After(0.5, function() StopChatFiltering(NPCTransmogInfo_Filter) end);
end

function NPC_ControlHelper.Funcs.LearnEpsiLocMarker()
	command("learn 160299");
end
---------------------------------------------------
-- Функции страницы [ФОРМАЦИИ]
---------------------------------------------------
local function NPCFormLead_GUID_Extractor(self, event, msg, ...)
	if msg:find(".+ is not a member .+") then
		printInfo("|cffBA6EE6[NPC Control Helper]|r |cffFFFF00Выбранный NPC не является частью формации (для того, чтобы создать формацию кликните на кнопку [Добавить] без указания GUID).|r");
		return true;
	elseif msg:find("Leader creature .+") then
		NPC_ControlHelper.Vars.LeadGUID = msg:match("Leader creature .+ (%d+)");
		Page2_NPC_GUIDBox:SetText(NPC_ControlHelper.Vars.LeadGUID);
		return true;
	elseif msg:find(".+ yd .+ deg") then
		return true;
	end
end

local function NPCFormLead_Add_Filter(self, event, msg, ...)
	if msg:find("Created new .+") then
		NPC_ControlHelper.Vars.LeadGUID = msg:match(".+ leader creature .+ (%d+)");
		Page2_NPC_GUIDBox:SetText(NPC_ControlHelper.Vars.LeadGUID);
		printInfo("|cffBA6EE6[NPC Control Helper]|r |cff00CC00Новая формация создана успешно.|r")
		return true;
	elseif msg:find(".+ is already member .+") then
		printInfo("|cffBA6EE6[NPC Control Helper]|r |cffFFFF00Выбранный NPC уже является частью формации.|r")
		return true;
	elseif msg:find("Creature .+ added to .+") then
		printInfo("|cffBA6EE6[NPC Control Helper]|r |cff00CC00NPC успешно добавлен в формацию.|r")
		return true;
	elseif msg:find(".+ is not a member .+") then
		printInfo("|cffBA6EE6[NPC Control Helper]|r |cffC61E1ENPC с указанным GUID не является лидером формации.|r");
		return true;
	end
end

local function NPCFormLead_Refresh_Filter(self, event, msg, ...)
	if msg:find("Created new .+") then
		NPC_ControlHelper.Vars.LeadGUID = msg:match(".+ leader creature .+ (%d+)");
		Page2_NPC_GUIDBox:SetText(NPC_ControlHelper.Vars.LeadGUID);
		printInfo("|cffBA6EE6[NPC Control Helper]|r |cff00CC00Новая формация создана успешно.|r")
		return true;
	elseif msg:find("Creature .+ added to .+") then
		printInfo("|cffBA6EE6[NPC Control Helper]|r |cff00CC00Позиция NPC относительно лидера успешно обновлена.|r")
		return true;
	elseif msg:find(".+ is not a member .+") then
		printInfo("|cffBA6EE6[NPC Control Helper]|r |cffC61E1ENPC с указанным GUID не является лидером формации.|r");
		return true;
	end
end

local function NPCFormLead_Remove_Filter(self, event, msg, ...)
	if msg:find(".+ is not a member .+") then
		printInfo("|cffBA6EE6[NPC Control Helper]|r |cffC61E1EВыбранный NPC не является частью какой-либо формации.|r");
		return true;
	elseif msg:find("Removed all creatures .+") then
		printInfo("|cffBA6EE6[NPC Control Helper]|r |cff00CC00Формация была распущена успешно.|r")
		return true;
	elseif msg:find("Removed creature .+") then
		printInfo("|cffBA6EE6[NPC Control Helper]|r |cff00CC00Выбранный NPC был успешно убран из формации.|r")
		return true;
	end
end

local function NPCFormLead_ShowNInfo_Filter(self, event, msg, ...)
	if msg:find(".+ is not a member .+") then
		printInfo("|cffBA6EE6[NPC Control Helper]|r |cffC61E1EВыбранный NPC не является частью какой-либо формации.|r");
		return true;
	end
end

function NPC_ControlHelper.Funcs.FormLead_GetGUID()
	StartChatFiltering(NPCFormLead_GUID_Extractor);
	command("np form inf ");
	C_Timer.After(0.5, function() StopChatFiltering(NPCFormLead_GUID_Extractor) end);
end

function NPC_ControlHelper.Funcs.Form_ThereAdd()	-- зарефакторить, вынести 3 последних строчки в отдельную функцию
	local FormLeadGUID = Page2_NPC_GUIDBox:GetText();
	StartChatFiltering(NPCFormLead_Add_Filter);
	command("np form add " .. FormLeadGUID);
	C_Timer.After(0.5, function() StopChatFiltering(NPCFormLead_Add_Filter) end);
end

function NPC_ControlHelper.Funcs.Form_ThereRef()	-- зарефакторить, вынести 4 последних строчки в отдельную функцию
	NPC_ControlHelper.Funcs.Form_Remove();
	local FormLeadGUID = Page2_NPC_GUIDBox:GetText();
	StartChatFiltering(NPCFormLead_Refresh_Filter);
	command("np form add " .. FormLeadGUID);
	C_Timer.After(0.5, function() StopChatFiltering(NPCFormLead_Refresh_Filter) end);
end

function NPC_ControlHelper.Funcs.Form_HereAdd()		-- зарефакторить, вынести 3 последних строчки в отдельную функцию
	local FormLeadGUID = Page2_NPC_GUIDBox:GetText();
	StartChatFiltering(NPCFormLead_Add_Filter);
	command("np form here " .. FormLeadGUID);
	C_Timer.After(0.5, function() StopChatFiltering(NPCFormLead_Add_Filter) end);
end

function NPC_ControlHelper.Funcs.Form_HereRef()		-- зарефакторить, вынести 4 последних строчки в отдельную функцию
	NPC_ControlHelper.Funcs.Form_Remove();
	local FormLeadGUID = Page2_NPC_GUIDBox:GetText();
	StartChatFiltering(NPCFormLead_Refresh_Filter);
	command("np form here " .. FormLeadGUID);
	C_Timer.After(0.5, function() StopChatFiltering(NPCFormLead_Refresh_Filter) end);
end

function NPC_ControlHelper.Funcs.Form_Remove()
	StartChatFiltering(NPCFormLead_Remove_Filter);
	command("np form rem");
	C_Timer.After(0.5, function() StopChatFiltering(NPCFormLead_Remove_Filter) end);
end

function NPC_ControlHelper.Funcs.Form_RefToggleOnClick(self)
	if self:GetChecked() then
		Page2_FormThereBtn:SetScript("OnClick", NPC_ControlHelper.Funcs.Form_ThereRef);
		Page2_FormThereBtnText:SetText("Обновить (поз. NPC)");
		Page2_FormHereBtn:SetScript("OnClick", NPC_ControlHelper.Funcs.Form_HereRef);
		Page2_FormHereBtnText:SetText("Обновить (поз. PLY)");
	else
		Page2_FormThereBtn:SetScript("OnClick", NPC_ControlHelper.Funcs.Form_ThereAdd);
		Page2_FormThereBtnText:SetText("Добавить (поз. NPC)");
		Page2_FormHereBtn:SetScript("OnClick", NPC_ControlHelper.Funcs.Form_HereAdd);
		Page2_FormHereBtnText:SetText("Добавить (поз. PLY)");
	end
end

function NPC_ControlHelper.Funcs.Form_Info()
	StartChatFiltering(NPCFormLead_ShowNInfo_Filter);
	command("np form info");
	C_Timer.After(0.5, function() StopChatFiltering(NPCFormLead_ShowNInfo_Filter) end);
end

function NPC_ControlHelper.Funcs.Form_Show()
	StartChatFiltering(NPCFormLead_ShowNInfo_Filter);
	command("np form show");
	C_Timer.After(0.5, function() StopChatFiltering(NPCFormLead_ShowNInfo_Filter) end);
end
---------------------------------------------------
-- Функции страницы [ДВИЖЕНИЕ]
---------------------------------------------------
function NPC_ControlHelper.Funcs.Movement_RunNWalk(movementType, where)
	local formationArg = "";
	if NPC_ControlHelper.Vars.FormationMovement then
		formationArg = "formation";
	else
		formationArg = "";
	end

	command("np " .. movementType .. " " .. where .. " " .. formationArg);
end

function NPC_ControlHelper.Funcs.Movement_FormToggleOnClick(self)
	if self:GetChecked() then
		NPC_ControlHelper.Vars.FormationMovement = true;
	else
		NPC_ControlHelper.Vars.FormationMovement = false;
	end
end

function NPC_ControlHelper.Funcs.Movement_Possessment(unposs)
	if unposs then
		command("unposs");
	else
		command("poss");
	end
end

function NPC_ControlHelper.Funcs.Movement_Turn(turntype)
	local formationArg = "";
	if NPC_ControlHelper.Vars.FormationMovement then
		formationArg = "form";
	else
		formationArg = "";
	end

	if turntype == "here" then
		command("np tu here " .. formationArg);
	elseif turntype == "there" then
		command("np tu there " .. formationArg);
	elseif turntype == "likeme" then
		command("np tu likeme " .. formationArg);
	end
end
---------------------------------------------------