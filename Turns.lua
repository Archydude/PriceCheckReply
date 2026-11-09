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

local offers = {} -- request key -> { [player GUID] = time their offer arrived }

-- A number for a piece of text, the same on every player's game.
local function hash(text)
	local h = 5381
	for i = 1, #text do h = (h * 33 + text:byte(i)) % 4294967296 end
	return h
end

-- Players are told apart by their character GUID, which every game sees the same way. Names
-- aren't safe for this: on WoW Forever a name has two parts ("Arch War"), UnitName gives them
-- separately, and other players' games see the whole name.
local function me()
	return UnitGUID("player") or "?"
end

-- Who answers a request, out of everyone who offered: the lowest score, so different requests go
-- to different players.
local function winner(key, players)
	local best, bestScore
	for player in pairs(players) do
		local score = hash(key .. "|" .. player)
		if not best or score < bestScore or (score == bestScore and player < best) then
			best, bestScore = player, score
		end
	end
	return best
end

local function forgetOld(now)
	for key, players in pairs(offers) do
		for player, at in pairs(players) do
			if now - at > WINDOW + SAME_ASK then players[player] = nil end
		end
		if next(players) == nil then offers[key] = nil end
	end
end

-- Runs answer() if this player is the one to answer a request seen in `chatType` chat with this
-- text. Whispers (and anything else without a shared channel) answer right away.
function ns.TakeTurns(chatType, text, answer)
	local channel = ADDON_CHANNEL[chatType]
	if not channel then return answer() end
	-- Where the realm doesn't let addons write in this chat, it doesn't let the hidden messages
	-- through either, so everyone answers (by whisper; see ns.CanAnswerIn).
	if not ns.CanAnswerIn(chatType) then return answer() end

	-- Written as a whole number, so every game writes the same key.
	local key = chatType .. ":" .. string.format("%.0f", hash(text))
	local now = GetTime()
	forgetOld(now)
	local mine = me()
	offers[key] = offers[key] or {}
	offers[key][mine] = now
	-- Newer games return 0 for a message that went out, older ones true or nothing.
	local sent = false
	if C_ChatInfo and C_ChatInfo.SendAddonMessage then
		local ok, result = pcall(C_ChatInfo.SendAddonMessage, PREFIX, key .. " " .. mine, channel)
		sent = ok and (result == nil or result == true or result == 0)
	end
	-- If the others can't hear this player, there's nothing to agree on: answer right away.
	if not sent then return answer() end

	C_Timer.After(WINDOW, function()
		local players = {}
		for player, at in pairs(offers[key] or {}) do
			if math.abs(at - now) <= SAME_ASK then players[player] = true end
		end
		players[mine] = true
		if winner(key, players) == mine then answer() end
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
-- An offer is "<request key> <player GUID>", like "GUILD:1234567 Player-1234-0ABCDEF0".
frame:SetScript("OnEvent", function(_, _, prefix, message)
	if prefix ~= PREFIX then return end
	if not ns.Readable(message) or type(message) ~= "string" then return end
	local key, player = message:match("^(%u[%u_]*:%d+) (Player%-[%w%-]+)$")
	if not key then return end
	offers[key] = offers[key] or {}
	offers[key][player] = GetTime()
end)
