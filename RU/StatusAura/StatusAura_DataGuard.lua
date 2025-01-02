---------------------------------------------------
-- SA_DataStruct_Up-to-dater_GetLibs
---------------------------------------------------
local SomeBodysUtils;

if LibStub then
	SomeBodysUtils = LibStub:GetLibrary("SomeBodysUtils");
else
	SomeBodysUtils = require("SomeBodysUtils");
end
---------------------------------------------------
-- Variables and Functions
---------------------------------------------------
local currentVersion = 180;
local function UpToDate_Function()
    if not StatusAuraVersion or StatusAuraVersion < currentVersion then
        ----------------------------------------------------
        local newPool = {};
        for _, aura in pairs(StatAurasDatabase.AurasPool) do
            local auraID = tostring(aura[1]);
            newPool[auraID] = aura;
        end
        StatAurasDatabase.AurasPool = newPool;  -- Update AurasPool
        StatAurasDatabase.NPCAuras = {};        -- Clear NPC auras from (most likely) garbage
    
        if StatAurasSyncModule then
            StatAurasSyncModule.whitelistedSenders = {};
            StatAurasSyncModule.autoWhitelist = true;
            StatAurasSyncModule.whitelistMode = true;
        end
        ----------------------------------------------------
        StatusAuraVersion = currentVersion;
    end
end

local function eventHandler(self, event, arg1, ...)
    if event == "ADDON_LOADED" and arg1 == "StatusAura" then
        UpToDate_Function();
    end
end
---------------------------------------------------
-- Functionality
---------------------------------------------------
local SA_DataStructRefresher_Frame = CreateFrame("Frame");
SA_DataStructRefresher_Frame:RegisterEvent("ADDON_LOADED");

SA_DataStructRefresher_Frame:SetScript("OnEvent", eventHandler);