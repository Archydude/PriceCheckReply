-- PriceCheck Reply: prices and the reply text
-- What an item goes for, from TSM or Auctionator, and the chat lines that answer a request.

local ADDON_NAME, ns = ...
local floor, format = math.floor, string.format

local PRICED_LINKS = { item = true, battlepet = true }
local MAX_ITEMS = 6      -- items answered in one request
local MAX_MESSAGES = 3   -- chat lines sent for one request
local MAX_BYTES = 255    -- the game's limit for one chat line, link codes included
local MAX_COUNT = 1000000

-- How each TSM price reads in a reply.
ns.TSM_SOURCES = {
	{ "dbmarket", "Market value (recommended)", "TSM market value" },
	{ "dbminbuyout", "Lowest auction right now", "TSM lowest auction" },
	{ "dbhistorical", "Historical price", "TSM historical" },
	{ "dbregionmarketavg", "Region market average", "TSM region average" },
}

local TSM_LABELS = {}
for _, source in ipairs(ns.TSM_SOURCES) do TSM_LABELS[source[1]] = source[3] end

---------------------------------------------------------------------------
-- Price addons
---------------------------------------------------------------------------

local function tsmLoaded()
	return TSM_API ~= nil and TSM_API.ToItemString ~= nil and TSM_API.GetCustomPriceValue ~= nil
end

local function auctionatorAPI()
	return Auctionator and Auctionator.API and Auctionator.API.v1
end

-- `addon` is the price addon a request asked for ("tsm" | "auctionator"), or nil for the setting.
local function useTSM(addon)
	return (addon or ns.db.provider) ~= "auctionator" and tsmLoaded()
end

local function useAuctionator(addon)
	return (addon or ns.db.provider) ~= "tsm" and auctionatorAPI() ~= nil
end

local LOADED = { tsm = tsmLoaded, auctionator = function() return auctionatorAPI() ~= nil end }
local ADDON_NAMES = { tsm = "TSM", auctionator = "Auctionator" }

-- Words an asker can add to a request to pick the price addon.
local ASK_WORDS = { tsm = "tsm", auc = "auctionator", auctionator = "auctionator" }

-- The price addon a request asks for, or nil.
local function askedAddon(text)
	if not ns.db.askerPicks then return end
	local words = ns.Words(text)
	for word, addon in pairs(ASK_WORDS) do
		if ns.HasWord(words, word) then return addon end
	end
end

-- Whether the chosen price addon is loaded, so there's something to answer with.
function ns.HasPriceAddon()
	return useTSM() or useAuctionator()
end

-- What the options page and the "can't answer" message say is missing.
function ns.MissingPriceAddon()
	if ns.db.provider == "tsm" then return "TSM is not loaded" end
	if ns.db.provider == "auctionator" then return "Auctionator is not loaded" end
	return "neither TSM nor Auctionator is loaded"
end

local function positive(ok, value)
	if ok and type(value) == "number" and value > 0 then return value end
end

local function tsmPrice(link)
	local ok, itemString = pcall(TSM_API.ToItemString, link)
	if not ok or not itemString then return end
	local source = ns.db.tsmSource
	local value = positive(pcall(TSM_API.GetCustomPriceValue, source, itemString))
	if value then return value, TSM_LABELS[source] or ("TSM " .. source) end
end

local function auctionatorPrice(link, kind)
	local api = auctionatorAPI()
	local value
	if api.GetAuctionPriceByItemLink then
		value = positive(pcall(api.GetAuctionPriceByItemLink, ADDON_NAME, link))
	end
	-- Some links Auctionator doesn't know by link it still knows by item.
	if not value and kind == "item" and api.GetAuctionPriceByItemID then
		local id = tonumber(link:match("|Hitem:(%d+)"))
		if id then value = positive(pcall(api.GetAuctionPriceByItemID, ADDON_NAME, id)) end
	end
	if not value then return end
	return value, "Auctionator", ns.AuctionatorAge(link)
end

-- One item's auction price, where it came from, and how old it is (Auctionator only), or nil.
-- `addon` as in useTSM.
local function auctionPrice(link, kind, addon)
	if useTSM(addon) then
		local value, label = tsmPrice(link)
		if value then return value, label end
	end
	if useAuctionator(addon) then return auctionatorPrice(link, kind) end
end

---------------------------------------------------------------------------
-- How old an Auctionator price is
---------------------------------------------------------------------------

local HOUR, DAY = 3600, 86400

-- When Auctionator last scanned the whole auction house (its full scan or its automatic one), or
-- nil. Auctionator keeps that in its own saved state, not its API, so a change on its side just
-- means no time in the answer.
local function lastScanTime()
	local state = Auctionator and Auctionator.SavedState
	if type(state) ~= "table" then return end
	local last
	for _, key in ipairs({ "TimeOfLastReplicateScan", "TimeOfLastBrowseScan", "TimeOfLastGetAllScan" }) do
		local t = state[key]
		if type(t) == "number" and t > 0 and (not last or t > last) then last = t end
	end
	return last
end

-- "updated 2h ago", "updated yesterday", "updated 5 days ago" for an item's Auctionator price, or
-- nil when Auctionator can't say. Auctionator only knows which day it last saw an item; for an item
-- seen today, the time of its last full scan narrows it down, when that scan was today too.
function ns.AuctionatorAge(link)
	local api = auctionatorAPI()
	if not (api and api.GetAuctionAgeByItemLink) then return end
	local ok, days = pcall(api.GetAuctionAgeByItemLink, ADDON_NAME, link)
	if not ok or type(days) ~= "number" then return end
	if days >= 2 then return format("updated %.0f days ago", days) end
	if days >= 1 then return "updated yesterday" end

	local scanned = lastScanTime()
	local ago = scanned and time() - scanned
	if not ago or ago < 0 or ago >= DAY then return "updated today" end
	if ago < HOUR then return format("updated %.0f min ago", math.max(1, floor(ago / 60))) end
	return format("updated %.0fh ago", floor(ago / HOUR))
end

---------------------------------------------------------------------------
-- Item details: vendor price and how it binds
---------------------------------------------------------------------------

-- Bind types that keep an item off the auction house, and how the answer says it.
local CANT_AUCTION = {
	[1] = "binds when picked up",
	[4] = "quest item",
	[7] = "binds to account",
	[8] = "warbound",
	[9] = "warbound until equipped",
}

local LOAD_WAIT, LOAD_CHECK = 2, 0.2 -- seconds to wait for item details, and how often to look

-- The item's details from the game, or nil when it doesn't have them loaded yet:
-- { sellPrice = copper or nil, bindType = number or nil }.
local function itemDetails(link)
	local getInfo = (C_Item and C_Item.GetItemInfo) or GetItemInfo
	local info = { pcall(getInfo, link) }
	if not info[1] or info[2] == nil then return end
	-- After pcall's "ok": name is 2nd, the vendor price 12th, the bind type 15th.
	return { sellPrice = positive(true, info[12]), bindType = info[15] }
end

-- Runs fn once the game has the details of every item linked in `text`, or after LOAD_WAIT
-- seconds if some never arrive (the answer then goes without them).
function ns.WhenLoaded(text, fn)
	local waiting = {}
	for _, item in ipairs(ns.ReadItems(text)) do
		if item.kind == "item" and not itemDetails(item.link) then
			waiting[#waiting + 1] = item.link
			local id = tonumber(item.link:match("|Hitem:(%d+)"))
			if id and C_Item and C_Item.RequestLoadItemDataByID then pcall(C_Item.RequestLoadItemDataByID, id) end
		end
	end
	if #waiting == 0 then return fn() end
	local waited = 0
	C_Timer.NewTicker(LOAD_CHECK, function(ticker)
		waited = waited + LOAD_CHECK
		for i = #waiting, 1, -1 do
			if itemDetails(waiting[i]) then table.remove(waiting, i) end
		end
		if #waiting == 0 or waited >= LOAD_WAIT - 0.001 then
			ticker:Cancel()
			fn()
		end
	end)
end

---------------------------------------------------------------------------
-- Money
---------------------------------------------------------------------------

-- 1234567 -> "1,234,567", in the game's own number grouping.
local function grouped(number)
	local text = format("%.0f", number)
	local separator = (LARGE_NUMBER_SEPERATOR or ","):gsub("%%", "%%%%")
	local count
	repeat
		text, count = text:gsub("^(%d+)(%d%d%d)", "%1" .. separator .. "%2")
	until count == 0
	return text
end

-- Copper -> "1,234g", "12g 34s", "34s 56c" or "56c". Chat lines can't show coin icons, so it's
-- plain text, and only the two biggest coins.
function ns.Coins(copper)
	copper = floor(copper + 0.5)
	local gold, silver, cop = floor(copper / 10000), floor(copper / 100) % 100, copper % 100
	local g, s, c = GOLD_AMOUNT_SYMBOL or "g", SILVER_AMOUNT_SYMBOL or "s", COPPER_AMOUNT_SYMBOL or "c"
	if gold >= 1000 then return grouped(gold) .. g end
	if gold > 0 then
		return silver > 0 and format("%.0f%s %.0f%s", gold, g, silver, s) or format("%.0f%s", gold, g)
	end
	if silver > 0 then
		return cop > 0 and format("%.0f%s %.0f%s", silver, s, cop, c) or format("%.0f%s", silver, s)
	end
	return format("%.0f%s", cop, c)
end

---------------------------------------------------------------------------
-- The request
---------------------------------------------------------------------------

-- The links in a message, each with how many were asked about: "20 [Linen Cloth]",
-- "20x [Linen Cloth]", "x20 [Linen Cloth]", "20 ?[Linen Cloth]" and "[Linen Cloth] x20" all ask
-- about 20, and so does "[Linen Cloth] 20" when the number ends the message (in the middle it
-- could belong to the next link). At most MAX_ITEMS.
function ns.ReadItems(text)
	local items = {}
	local searchFrom, lastEnd = 1, 0
	while #items < MAX_ITEMS do
		local first, last, kind = text:find(ns.LINK_PATTERN, searchFrom)
		if not first then break end
		local count = text:sub(lastEnd + 1, first - 1):match("(%d+)%s*[xX]?%s*%??%s*$")
		local link = text:sub(first, last)
		local afterCount, afterEnd = text:match("^%s*[xX]%s*(%d+)()", last + 1)
		if not afterCount then afterCount, afterEnd = text:match("^%s*(%d+)%s*()$", last + 1) end
		if afterCount then
			count = afterCount
			last = afterEnd - 1
		end
		if PRICED_LINKS[kind] then
			count = math.min(math.max(tonumber(count) or 1, 1), MAX_COUNT)
			items[#items + 1] = { link = link, kind = kind, count = count }
		end
		searchFrom, lastEnd = last + 1, last
	end
	return items
end

-- "[Name]" from a link, without its colors or quality icon, for when the link won't fit.
local function plainName(link)
	local name = link:match("|h(.-)|h") or link
	return (name:gsub("|A.-|a", ""):gsub("|T.-|t", ""):gsub("%s+%]", "]"))
end

-- TSM's region numbers for an item: the share of its auctions that sell, and how many sell a
-- day. TSM gives the rate as a fraction and the daily count as a plain number, but rounds every
-- custom price to a whole number, so a rate of 0.37 would come back as 0 and 0.62 as 1. Like
-- TSM's own tooltip, ask for them times 1000 and divide. Either is nil when TSM has none, or when
-- its option is off.
local function tsmNumber(source, itemString)
	local value = positive(pcall(TSM_API.GetCustomPriceValue, source .. " * 1000", itemString))
	return value and value / 1000
end

local function regionStats(link)
	if not (ns.db.showSaleRate or ns.db.showSoldPerDay) or not tsmLoaded() then return end
	local ok, itemString = pcall(TSM_API.ToItemString, link)
	if not ok or not itemString then return end
	return ns.db.showSaleRate and tsmNumber("dbregionsalerate", itemString) or nil,
		ns.db.showSoldPerDay and tsmNumber("dbregionsoldperday", itemString) or nil
end

-- "94%", or "0.4%" under one percent.
local function percentText(rate)
	local percent = rate * 100
	return (percent < 1 and format("%.1f", percent) or format("%.0f", percent)) .. "%"
end

-- "2.4" under ten, then whole numbers: "2,847" in full, or "2.8k" and "1.2m" when short.
local function perDayText(perDay, short)
	if perDay < 10 then return (format("%.1f", perDay):gsub("%.0$", "")) end
	if short and perDay >= 999500 then return (format("%.1f", perDay / 1000000):gsub("%.0$", "")) .. "m" end
	if short and perDay >= 999.5 then return (format("%.1f", perDay / 1000):gsub("%.0$", "")) .. "k" end
	return grouped(floor(perDay + 0.5))
end

-- The region numbers as notes. In full for one item ("region sale rate 94%", "region sells
-- 2,847/day"); short in a list ("sells 94%", "2.8k/day").
local function regionNotes(info, notes, short)
	if info.saleRate then
		notes[#notes + 1] = (short and "sells " or "region sale rate ") .. percentText(info.saleRate)
	end
	if info.perDay then
		notes[#notes + 1] = (short and "" or "region sells ") .. perDayText(info.perDay, short) .. "/day"
	end
end

-- What the answer needs to know about one item: its price for the count asked, where that came
-- from, how old it is, TSM's region numbers, or why it has no price. request.addon is the price
-- addon the asker picked.
local function lookUp(item, request)
	local info = { item = item }
	local details = item.kind == "item" and itemDetails(item.link)
	local vendor = ns.db.vendorPrice and details and details.sellPrice
	info.vendorText = vendor and (", sells to a vendor for " .. ns.Coins(vendor * item.count)) or ""
	info.bound = details and CANT_AUCTION[details.bindType]
	if info.bound then return info end
	local each, label, age = auctionPrice(item.link, item.kind, request.addon)
	if each then
		info.each, info.value = each, each * item.count
		if label and (ns.db.showSource or request.addon or request.missing) then info.label = label end
		if age and ns.db.showAge then info.age = age end
		info.saleRate, info.perDay = regionStats(item.link)
	end
	return info
end

-- "20x [Linen Cloth]", or just the item for one. `shown` is its link, or its plain name when the
-- link won't fit.
local function named(info, shown)
	return info.item.count > 1 and format("%.0fx %s", info.item.count, shown) or shown
end

-- An item with no price: bound, or no auction data.
local function unpriced(info, what, request)
	if info.bound then return what .. ": " .. info.bound .. ", can't be auctioned" .. info.vendorText end
	local text = what .. ": no auction data"
	if request.addon then text = text .. " in " .. ADDON_NAMES[request.addon] end
	return text .. info.vendorText
end

local function withNotes(text, notes)
	if #notes == 0 then return text end
	return text .. " (" .. table.concat(notes, ", ") .. ")"
end

-- The answer about a single item: "20x [Linen Cloth]: 5g 6s (25s 30c each, TSM market value)".
-- request.missing is the addon the asker picked that isn't installed.
local function single(info, shown, request)
	local what = named(info, shown)
	if not info.value then return unpriced(info, what, request) end
	local notes = {}
	if info.item.count > 1 then notes[#notes + 1] = ns.Coins(info.each) .. " each" end
	if info.label then notes[#notes + 1] = info.label end
	if info.age then notes[#notes + 1] = info.age end
	regionNotes(info, notes, false)
	if request.missing then notes[#notes + 1] = "no " .. ADDON_NAMES[request.missing] .. " here" end
	return withNotes(what .. ": " .. ns.Coins(info.value), notes)
end

-- One item in the list under a total: "200x [Linen Cloth] 54s". Where its price came from and
-- how old it is go on the total line instead when every item shares them (`shared`).
local function listed(info, shown, request, shared)
	local what = named(info, shown)
	if not info.value then return unpriced(info, what, request) end
	local notes = {}
	if info.label and info.label ~= shared.label then notes[#notes + 1] = info.label end
	if info.age and info.age ~= shared.age then notes[#notes + 1] = info.age end
	regionNotes(info, notes, true)
	return withNotes(what .. " " .. ns.Coins(info.value), notes)
end

-- The one value every priced item has for `key` ("label" or "age"), or nil when they differ or
-- some have none.
local function sharedValue(infos, key)
	local value
	for _, info in ipairs(infos) do
		if info.value then
			local this = info[key]
			if not this or (value and value ~= this) then return end
			value = this
		end
	end
	return value
end

-- "Total: 3g 47s for 3 items (TSM market value)". Items without a price aren't in it, and then
-- it says so: "for 2 of 3 items". Nil when no item has a price.
local function totalLine(infos, request, shared)
	local sum, priced = 0, 0
	for _, info in ipairs(infos) do
		if info.value then sum, priced = sum + info.value, priced + 1 end
	end
	if priced == 0 then return end
	local text = "Total: " .. ns.Coins(sum)
		.. (priced < #infos and format(" for %d of %d items", priced, #infos) or format(" for %d items", #infos))
	local notes = {}
	if shared.label then notes[#notes + 1] = shared.label end
	if shared.age then notes[#notes + 1] = shared.age end
	if request.missing then notes[#notes + 1] = "no " .. ADDON_NAMES[request.missing] .. " here" end
	return withNotes(text, notes)
end

-- Whether a message can be answered: the price addon it asks for, or else the one in the
-- settings, is loaded.
function ns.CanAnswer(text)
	local addon = askedAddon(text)
	return (addon and LOADED[addon]()) or ns.HasPriceAddon()
end

-- The chat lines answering a message, or nil when it has no item or pet links. One item gets one
-- line. Several get the total first, then the items packed into as few lines as fit; a part too
-- long for a line on its own loses its link, and items that don't fit in MAX_MESSAGES lines are
-- left out and counted ("and 2 more").
function ns.BuildReply(text)
	local items = ns.ReadItems(text)
	if #items == 0 then return end
	local request = { addon = askedAddon(text) }
	if request.addon and not LOADED[request.addon]() then
		request.missing, request.addon = request.addon, nil
	end
	local infos = {}
	for i, item in ipairs(items) do infos[i] = lookUp(item, request) end

	if #infos == 1 then
		local part = single(infos[1], items[1].link, request)
		if #part > MAX_BYTES then part = single(infos[1], plainName(items[1].link), request) end
		return { part }
	end

	local shared = { label = sharedValue(infos, "label"), age = sharedValue(infos, "age") }
	local lines, perLine = {}, {}
	local total = totalLine(infos, request, shared)
	if total then lines[1], perLine[1] = total, 0 end
	local current, count
	for _, info in ipairs(infos) do
		local part = listed(info, info.item.link, request, shared)
		if #part > MAX_BYTES then part = listed(info, plainName(info.item.link), request, shared) end
		if current and #current + 2 + #part <= MAX_BYTES then
			current, count = current .. "; " .. part, count + 1
		else
			if current then lines[#lines + 1], perLine[#lines + 1] = current, count end
			current, count = part, 1
		end
	end
	lines[#lines + 1], perLine[#lines + 1] = current, count

	if #lines > MAX_MESSAGES then
		local left = 0
		while #lines > MAX_MESSAGES do
			left = left + perLine[#lines]
			table.remove(lines); table.remove(perLine)
		end
		local more = format("; and %d more", left)
		if #lines[#lines] + #more <= MAX_BYTES then lines[#lines] = lines[#lines] .. more end
	end
	return lines
end
