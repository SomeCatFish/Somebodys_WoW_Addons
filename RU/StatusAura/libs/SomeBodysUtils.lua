local SomeBodysUtils;
local next = next;

if LibStub then
    SomeBodysUtils = LibStub:NewLibrary("SomeBodysUtils", 1);
else
    SomeBodysUtils = {};
end

if not SomeBodysUtils then
	return;
end

function SomeBodysUtils:removebykey(table, key)
    local element = table[key];
    table[key] = nil;
    return element;
end

function SomeBodysUtils:AuraTableCopy(table)
	local table2 = {};
	for i, n in pairs(table) do
	  table2[i] = n;
	end
	return table2;
end

function SomeBodysUtils:addToSetTable(setTable, key)
    setTable[key] = true;
end

function SomeBodysUtils:removeFromSetTable(setTable, key)	-- Basically the same as removebykey() BUT left separate for clarity.
    setTable[key] = nil;
end

function SomeBodysUtils:tableContains(setTable, key)
    return setTable[key] ~= nil;
end

function SomeBodysUtils:tableIsEmpty(setTable)
    return next(setTable) == nil;
end
-- print(SomeBodysUtils:tableContains(StatAurasDatabase, "AurasPool"));