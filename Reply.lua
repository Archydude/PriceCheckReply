-- PriceCheck Reply: answering
-- Reads whispers and the chosen chat channels, decides whether a message is a price request from
-- someone the player wants to answer, and sends the answer back the same way it came.

local _, ns = ...

-- Chat events -> the setting that says whether and how to answer, and the channel to answer in.
-- Channel settings are "off", "channel" (answer in `reply`) or "whisper" (whisper the asker).
local CHANNELS = {
	CHAT_MSG_WHISPER = { reply = "WHISPER" },
	CHAT_MSG_BN_WHISPER = { setting = "bnet", reply = "BN_WHISPER" },
	CHAT_MSG_GUILD = { setting = "guildReply", reply = "GUILD" },
	CHAT_MSG_OFFICER = { setting = "officerReply", reply = "OFFICER" },
	CHAT_MSG_PARTY = { setting = "groupReply", reply = "PARTY" },
	CHAT_MSG_PARTY_LEADER = { setting = "groupReply", reply = "PARTY" },
	CHAT_MSG_RAID = { setting = "groupReply", reply = "RAID" },
	CHAT_MSG_RAID_LEADER = { setting = "groupReply", reply = "RAID" },
	CHAT_MSG_INSTANCE_CHAT = { setting = "groupReply", reply = "INSTANCE_CHAT" },
	CHAT_MSG_INSTANCE_CHAT_LEADER = { setting = "groupReply", reply = "INSTANCE_CHAT" },
}

-- The same answer isn't sent to the same place twice within this many seconds. That also stops two
-- players running the addon from answering each other in a loop.
local REPEAT_WINDOW = 10
-- At most this many lines sent in any RATE_WINDOW seconds, so a flood of requests can't get the
-- player muted for spam.
local RATE_LINES, RATE_WINDOW = 8, 15
-- Seconds between the lines of one answer. Lines sent in the same moment can reach the asker out
-- of order (seen on WoW Forever), and the total has to come first.
local LINE_GAP = 0.3

local SendChat = (C_ChatInfo and C_ChatInfo.SendChatMessage) or SendChatMessage
local SendBNetWhisper = (C_BattleNet and C_BattleNet.SendWhisper) or BNSendWhisper

---------------------------------------------------------------------------
-- Who's asking
---------------------------------------------------------------------------

-- Calls a game function that may not exist on this version or may refuse odd input.
local function ask(fn, ...)
	if not fn then return end
	local ok, result = pcall(fn, ...)
	return ok and result
end

local function shortName(name)
	return Ambiguate and Ambiguate(name, "none") or name
end

local function isMe(sender, guid)
	if guid and guid == UnitGUID("player") then return true end
	return shortName(sender) == UnitName("player")
end

local function isFriend(sender, guid)
	if guid then
		if C_FriendList and ask(C_FriendList.IsFriend, guid) then return true end
		-- A Battle.net friend's character.
		if C_BattleNet and (ask(C_BattleNet.GetAccountInfoByGUID, guid) or ask(C_BattleNet.GetGameAccountInfoByGUID, guid)) then
			return true
		end
	end
	return C_FriendList ~= nil and ask(C_FriendList.GetFriendInfo, shortName(sender)) ~= nil
end

local function isGuildMate(sender, guid)
	if not IsInGuild() then return false end
	if guid and ask(IsGuildMember, guid) then return true end
	local name = shortName(sender)
	if C_GuildInfo and ask(C_GuildInfo.MemberExistsByName, name) then return true end
	for i = 1, GetNumGuildMembers() do
		local member = GetGuildRosterInfo(i)
		if member and shortName(member) == name then return true end
	end
	return false
end

local function wantsWhisperFrom(sender, guid)
	local db = ns.db
	return db.whisperAnyone
		or (db.whisperFriends and isFriend(sender, guid))
		or (db.whisperGuild and isGuildMate(sender, guid))
end

---------------------------------------------------------------------------
-- Is it a request
---------------------------------------------------------------------------

-- Whether a "?" starts a word and is followed by an item link, maybe with a count in between:
-- "?[Linen Cloth]", "? 20 [Linen Cloth]", "?x20 [Linen Cloth]". "what drops this? [item]" doesn't count, since the "?"
-- ends a word there.
local function hasShortTrigger(text)
	local from = 1
	while true do
		local at = text:find("?", from, true)
		if not at then return false end
		if at == 1 or text:sub(at - 1, at - 1):find("%s") then
			local rest = text:sub(at + 1)
			if rest:find("^%s*|c") or rest:find("^%s*[xX]?%s*%d+%s*[xX]?%s*|c") then return true end
		end
		from = at + 1
	end
end

-- Whether the message is a request: "?pc" as a word of its own outside item links (upper and
-- lower case don't matter), or "?" right before an item link.
local function hasTrigger(text)
	return ns.HasWord(ns.Words(text), ns.TRIGGER) or hasShortTrigger(text)
end

---------------------------------------------------------------------------
-- Sending
---------------------------------------------------------------------------

local lastSent = {}  -- place .. answer -> time sent
local sendTimes = {} -- times of recent lines, oldest first
local warnedRate, warnedNoAddon = false, false

local function roomToSend(count)
	local now = GetTime()
	while sendTimes[1] and now - sendTimes[1] > RATE_WINDOW do table.remove(sendTimes, 1) end
	return #sendTimes + count <= RATE_LINES
end

local function send(lines, chatType, target)
	-- Retail stops addons sending chat during boss fights, Mythic+ and PvP matches.
	if C_ChatInfo and ask(C_ChatInfo.InChatMessagingLockdown) then return end

	local place = chatType .. ":" .. tostring(target or "")
	local answer = table.concat(lines, "\n")
	local now = GetTime()
	for key, sentAt in pairs(lastSent) do
		if now - sentAt >= REPEAT_WINDOW then lastSent[key] = nil end
	end
	if lastSent[place .. answer] and now - lastSent[place .. answer] < REPEAT_WINDOW then return end
	if not roomToSend(#lines) then
		if not warnedRate then
			warnedRate = true
			ns.Print("too many price requests at once; some went unanswered.")
		end
		return
	end
	lastSent[place .. answer] = now

	local function sendLine(line)
		if chatType == "BN_WHISPER" then
			SendBNetWhisper(target, line)
		else
			SendChat(line, chatType, nil, target)
		end
	end
	for i, line in ipairs(lines) do
		sendTimes[#sendTimes + 1] = now
		if i == 1 then
			sendLine(line)
		else
			C_Timer.After((i - 1) * LINE_GAP, function() sendLine(line) end)
		end
	end
end

---------------------------------------------------------------------------
-- Chat
---------------------------------------------------------------------------

local function onChat(event, ...)
	local db = ns.db
	if not db.enabled then return end
	local channel = CHANNELS[event]
	local how = channel.setting and db[channel.setting]
	if how == false or how == "off" then return end

	local text, sender = ...
	local flags, guid, bnSenderID = select(6, ...), select(12, ...), select(13, ...)
	-- Inside instances the game hides chat from addons; there's nothing to read there.
	if not (ns.Readable(text) and ns.Readable(sender) and ns.Readable(guid)) then return end
	if type(text) ~= "string" or type(sender) ~= "string" then return end
	if flags == "GM" or flags == "DEV" then return end

	local replyType, target = channel.reply, nil
	if event == "CHAT_MSG_BN_WHISPER" then
		if not ns.Readable(bnSenderID) or not bnSenderID then return end
		target = bnSenderID
	else
		if isMe(sender, guid) then return end
		if event == "CHAT_MSG_WHISPER" then
			if not wantsWhisperFrom(sender, guid) then return end
			target = sender
		elseif how == "whisper" or not ns.CanAnswerIn(channel.reply) then
			replyType, target = "WHISPER", sender
		end
	end

	if not hasTrigger(text) then return end
	if not ns.CanAnswer(text) then
		if not warnedNoAddon then
			warnedNoAddon = true
			ns.Print(shortName(sender) .. " asked for a price, but " .. ns.MissingPriceAddon() .. ".")
		end
		return
	end
	-- In a shared chat, only one of the players with the addon answers.
	ns.TakeTurns(channel.reply, text, function()
		ns.WhenLoaded(text, function()
			local lines = ns.BuildReply(text)
			if lines then send(lines, replyType, target) end
		end)
	end)
end

function ns.StartListening()
	local frame = CreateFrame("Frame")
	for event in pairs(CHANNELS) do
		-- Some chat types don't exist on every version (instance chat on Classic Era).
		pcall(frame.RegisterEvent, frame, event)
	end
	frame:SetScript("OnEvent", function(_, event, ...) onChat(event, ...) end)
end
