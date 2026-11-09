-- PriceCheck Reply: taking turns
-- When several players in the same guild or group have the addon, a request in that chat gets one
-- answer instead of one from each of them. Everyone who would answer says so to the others over a
-- hidden addon channel, waits a moment to hear who else will, and then each of them works out the
-- same winner from the same list. Only the winner answers. Whispers don't need this.

local _, ns = ...

local PREFIX = "PCReply"
local WINDOW = 1      -- seconds to hear from the others before deciding
local SAME_ASK = 3    -- seconds apart that two players' offers can be and still be for the same request

-- The hidden channel to talk over, for each chat a request can come from.
local ADDON_CHANNEL = {
	GUILD = "GUILD", OFFICER = "OFFICER", PARTY = "PARTY", RAID = "RAID", INSTANCE_CHAT = "INSTANCE_CHAT",
}

local offers = {} -- request key -> { [player name] = time their offer arrived }

-- A number for a piece of text, the same on every player's game.
local function hash(text)
	local h = 5381
	for i = 1, #text do h = (h * 33 + text:byte(i)) % 4294967296 end
	return h
end

-- "name-realm" in lower case, the way other players' games see a name. The realm isn't known for
-- a moment after login, so the player's own name isn't kept until it is.
local myName
local function fullName(name)
	if not name:find("-", 1, true) then
		local realm = GetNormalizedRealmName and GetNormalizedRealmName()
		if realm and realm ~= "" then name = name .. "-" .. realm end
	end
	return name:lower()
end

local function me()
	if myName then return myName end
	local name = fullName(UnitName("player"))
	if name:find("-", 1, true) then myName = name end
	return name
end

-- Who answers a request, out of everyone who offered: the lowest score, so different requests go
-- to different players.
local function winner(key, names)
	local best, bestScore
	for name in pairs(names) do
		local score = hash(key .. "|" .. name)
		if not best or score < bestScore or (score == bestScore and name < best) then
			best, bestScore = name, score
		end
	end
	return best
end

local function forgetOld(now)
	for key, names in pairs(offers) do
		for name, at in pairs(names) do
			if now - at > WINDOW + SAME_ASK then names[name] = nil end
		end
		if next(names) == nil then offers[key] = nil end
	end
end

-- Runs answer() if this player is the one to answer a request seen in `chatType` chat with this
-- text. Whispers (and anything else without a shared channel) answer right away.
function ns.TakeTurns(chatType, text, answer)
	local channel = ADDON_CHANNEL[chatType]
	if not channel then return answer() end
	-- Where the realm doesn't let addons send messages, no one can hear the others, so everyone
	-- answers (by whisper; see ns.OutgoingChatAllowed).
	if not ns.OutgoingChatAllowed() then return answer() end

	-- Written as a whole number, so every game writes the same key.
	local key = chatType .. ":" .. string.format("%.0f", hash(text))
	local now = GetTime()
	forgetOld(now)
	local mine = me()
	offers[key] = offers[key] or {}
	offers[key][mine] = now
	if C_ChatInfo and C_ChatInfo.SendAddonMessage then
		pcall(C_ChatInfo.SendAddonMessage, PREFIX, key, channel)
	end

	C_Timer.After(WINDOW, function()
		local names = {}
		for name, at in pairs(offers[key] or {}) do
			if math.abs(at - now) <= SAME_ASK then names[name] = true end
		end
		names[mine] = true
		if winner(key, names) == mine then answer() end
	end)
end

---------------------------------------------------------------------------
-- Hearing the others
---------------------------------------------------------------------------

if C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix then
	C_ChatInfo.RegisterAddonMessagePrefix(PREFIX)
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("CHAT_MSG_ADDON")
frame:SetScript("OnEvent", function(_, _, prefix, message, _, sender)
	if prefix ~= PREFIX then return end
	if not (ns.Readable(message) and ns.Readable(sender)) then return end
	if type(message) ~= "string" or type(sender) ~= "string" then return end
	if not message:find("^%u[%u_]*:%d+$") then return end
	offers[message] = offers[message] or {}
	offers[message][fullName(sender)] = GetTime()
end)
