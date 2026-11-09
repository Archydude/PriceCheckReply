-- PriceCheck Reply
-- Answers players who send "?pc" and one or more item links with
-- each item's auction price from TSM or Auctionator. Who gets answered (friends, guild mates,
-- anyone; whispers, guild, officer or group chat) is up to the player.
--
-- Files, in load order (see the .toc):
--   Core.lua      namespace, saved settings, slash command
--   Prices.lua    what an item is worth, and the reply text
--   Turns.lua     one answer per request when several players in a chat have the addon
--   Reply.lua     reading chat, deciding whether to answer, sending the answer
--   Options.lua   Esc > Options > AddOns > PriceCheck Reply

local ADDON_NAME, ns = ...

ns.ADDON_NAME = ADDON_NAME
ns.PREFIX = "|cff33ff99PriceCheck Reply:|r "

function ns.Print(text)
	DEFAULT_CHAT_FRAME:AddMessage(ns.PREFIX .. text)
end

-- Whether a value the game handed us can be read. In instances and combat the game can hide chat
-- from addons.
function ns.Readable(value)
	return not (issecretvalue and issecretvalue(value))
end

-- An item or battle pet link in chat. Retail links can carry a quality icon inside the name, so
-- the name runs up to the link's end rather than up to the next "|".
ns.LINK_PATTERN = "|c[^|]*|H(%a+):[^|]*|h.-|h|r"

-- A message's text without its item links, in lower case, so words can be looked for in it
-- without matching item names.
function ns.Words(text)
	return (text:gsub(ns.LINK_PATTERN, " "):lower())
end

-- Whether `word` (lower case) is in `words` (from ns.Words) on its own, not as part of a longer
-- word: "?pc" is in "?pc [x]" but not in "?pcs [x]".
function ns.HasWord(words, word)
	local startsWord, endsWord = word:find("^%w"), word:find("%w$")
	local from = 1
	while true do
		local first, last = words:find(word, from, true)
		if not first then return false end
		local before, after = words:sub(first - 1, first - 1), words:sub(last + 1, last + 1)
		if not (startsWord and before:find("%w")) and not (endsWord and after:find("%w")) then return true end
		from = first + 1
	end
end

---------------------------------------------------------------------------
-- Saved settings
---------------------------------------------------------------------------

-- What a message has to contain, besides an item link, to get an answer. A "?" right before a link
-- works too (see Reply.lua). Both are fixed, so everyone asks the same way.
ns.TRIGGER = "?pc"

-- Whether answers can go into guild, officer, party and raid chat. The game engine with secret
-- values (Retail and WoW Forever) blocks addons from writing there, even in direct reply to a
-- message (seen on Forever 1.60.1); whispers still work. There, those requests get a whisper.
ns.CAN_ANSWER_IN_CHANNEL = not issecretvalue

ns.DEFAULTS = {
	enabled = true,
	-- Whispers, by who sent them.
	whisperFriends = true,   -- friends list and Battle.net friends' characters
	whisperGuild = true,     -- guild mates
	whisperAnyone = false,   -- everyone else
	bnet = true,             -- Battle.net whispers
	-- Channels: "off" | "channel" (answer in the same channel) | "whisper" (whisper the asker).
	guildReply = "off",
	officerReply = "off",
	groupReply = "off",      -- party, raid and instance chat
	-- Prices.
	provider = "auto",       -- "auto" | "tsm" | "auctionator"
	askerPicks = true,       -- "tsm" or "auc" in a request picks the price addon
	tsmSource = "dbmarket",
	showSource = true,       -- say where each price comes from
	showAge = true,          -- say how old an Auctionator price is
	vendorPrice = true,      -- mention the vendor price when there's no auction price
}

---------------------------------------------------------------------------
-- Loading
---------------------------------------------------------------------------

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:SetScript("OnEvent", function(self, _, name)
	if name ~= ADDON_NAME then return end
	self:UnregisterEvent("ADDON_LOADED")
	PriceCheckReplyDB = PriceCheckReplyDB or {}
	for key, value in pairs(ns.DEFAULTS) do
		if PriceCheckReplyDB[key] == nil then PriceCheckReplyDB[key] = value end
	end
	-- Settings that no longer exist (the channel checkboxes before they became choices, the trigger).
	for key in pairs(PriceCheckReplyDB) do
		if ns.DEFAULTS[key] == nil then PriceCheckReplyDB[key] = nil end
	end
	-- "Answer in the same chat" chosen where the game doesn't allow it becomes a whisper.
	if not ns.CAN_ANSWER_IN_CHANNEL then
		for _, key in ipairs({ "guildReply", "officerReply", "groupReply" }) do
			if PriceCheckReplyDB[key] == "channel" then PriceCheckReplyDB[key] = "whisper" end
		end
	end
	ns.db = PriceCheckReplyDB
	ns.CreateOptions()
	ns.StartListening()
end)

---------------------------------------------------------------------------
-- Slash command
---------------------------------------------------------------------------

local function help()
	ns.Print("commands:")
	print("  /pricereply - options")
	print("  /pricereply on | off - answer price requests or not")
	print("  /pricereply test <item link> - show the answer you'd send, only to you (add tsm or auc to pick the price addon)")
end

SLASH_PRICECHECKREPLY1 = "/pricereply"
SLASH_PRICECHECKREPLY2 = "/pcreply"
SlashCmdList.PRICECHECKREPLY = function(msg)
	msg = strtrim(msg or "")
	local command, rest = msg:match("^(%S*)%s*(.-)$")
	command = command:lower()
	if command == "" then
		ns.OpenOptions()
	elseif command == "on" or command == "off" then
		ns.SetSetting("enabled", command == "on")
		ns.Print(command == "on" and "answering price requests." or "not answering price requests.")
	elseif command == "test" then
		ns.WhenLoaded(rest, function()
			local lines = ns.BuildReply(rest)
			if not lines then
				ns.Print("put an item link after /pricereply test (Shift-click an item).")
				return
			end
			for _, line in ipairs(lines) do ns.Print(line) end
		end)
	else
		help()
	end
end
