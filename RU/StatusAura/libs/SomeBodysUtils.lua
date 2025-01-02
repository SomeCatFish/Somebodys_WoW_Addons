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

function SomeBodysUtils:removeFromSetTable(setTable, key)
    setTable[key] = nil;
end

function SomeBodysUtils:tableContains(setTable, key)
    return setTable[key] ~= nil;
end

function SomeBodysUtils:sizeOfSetTable(setTable)
    local n = 0;
    for _, _ in pairs(setTable) do
        n = n + 1;
    end
    return n;
end

function SomeBodysUtils:tableIsEmpty(setTable)
    return next(setTable) == nil;
end