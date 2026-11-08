-- PriceCheck Reply: options
-- Esc > Options > AddOns > PriceCheck Reply.

local _, ns = ...

local category
local settings = {} -- key -> the options page's setting object

function ns.OpenOptions()
	if category then Settings.OpenToCategory(category:GetID()) end
end

-- Changes a setting from elsewhere (the slash command) through the options page, so it stays in sync.
function ns.SetSetting(key, value)
	if settings[key] then
		settings[key]:SetValue(value)
	else
		ns.db[key] = value
	end
end

function ns.CreateOptions()
	local layout
	category, layout = Settings.RegisterVerticalLayoutCategory("PriceCheck Reply")
	local VarType = Settings.VarType or { Boolean = "boolean", String = "string" }

	-- Section headings; skipped on clients that can't draw them.
	local function header(text)
		if CreateSettingsListSectionHeaderInitializer then
			layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(text))
		end
	end

	local function setting(key, varType, name)
		local s = Settings.RegisterAddOnSetting(category, "PRICECHECKREPLY_" .. key:upper(), key, ns.db, varType, name,
			ns.DEFAULTS[key])
		settings[key] = s
		return s
	end

	local function checkbox(key, name, tooltip)
		Settings.CreateCheckbox(category, setting(key, VarType.Boolean, name), tooltip)
	end

	local function dropdown(key, name, choices, tooltip)
		local function getOptions()
			local container = Settings.CreateControlTextContainer()
			for _, choice in ipairs(choices) do container:Add(choice[1], choice[2]) end
			return container:GetData()
		end
		Settings.CreateDropdown(category, setting(key, VarType.String, name), getOptions, tooltip)
	end

	checkbox("enabled", "Answer price requests",
		"Answer messages with ?pc and one or more item links, like \"?pc [Linen Cloth]\", or with ? right before a link, like \"?[Linen Cloth]\". A number before an item asks about that many: \"?pc 20 [Linen Cloth]\". "
			.. "Same as /pricereply on and /pricereply off.")

	header("Whispers")
	checkbox("whisperFriends", "From friends",
		"Answer whispers from characters on your friends list and from your Battle.net friends' characters.")
	checkbox("whisperGuild", "From guild mates", "Answer whispers from members of your guild.")
	checkbox("whisperAnyone", "From anyone",
		"Answer whispers from everyone, strangers included.")
	checkbox("bnet", "Battle.net whispers", "Answer Battle.net whispers from your Battle.net friends.")

	header("Channels")
	local function channel(key, name, chat, tooltip)
		dropdown(key, name, {
			{ "off", "Don't answer" },
			{ "channel", "Answer in " .. chat },
			{ "whisper", "Whisper the asker" },
		}, tooltip .. " Answering in " .. chat .. " lets everyone there see the price; a whisper keeps it between you and the asker."
			.. " When others there have PriceCheck Reply too, only one of you answers each request.")
	end
	channel("guildReply", "Guild chat", "guild chat", "Whether to answer requests made in guild chat, and how.")
	channel("officerReply", "Officer chat", "officer chat", "Whether to answer requests made in officer chat, and how.")
	channel("groupReply", "Party and raid chat", "the same chat",
		"Whether to answer requests made in party, raid and instance chat, and how."
			.. (issecretvalue and " Inside dungeons, raids and battlegrounds the game doesn't let addons read chat, so no answers there." or ""))

	header("Prices")
	dropdown("provider", "Price addon", {
		{ "auto", "Automatic (TSM, then Auctionator)" },
		{ "tsm", "TradeSkillMaster only" },
		{ "auctionator", "Auctionator only" },
	}, "Where prices come from. Automatic uses TSM and falls back to Auctionator for items TSM has no price for.")
	checkbox("askerPicks", "Askers can pick the price addon",
		"Someone who adds \"tsm\" or \"auc\" to a request, like \"?pc auc [Linen Cloth]\", gets that addon's price instead. "
			.. "If you don't have the addon they asked for, the answer comes from the other one and says so.")
	local tsmChoices = {}
	for _, source in ipairs(ns.TSM_SOURCES) do tsmChoices[#tsmChoices + 1] = { source[1], source[2] } end
	dropdown("tsmSource", "TSM price", tsmChoices,
		"Which TSM price to answer with. Market value smooths out spikes; lowest auction is what's listed right now.")
	checkbox("showSource", "Say where prices come from",
		"Add the price addon to each answer, like \"(TSM market value)\".")
	checkbox("showAge", "Say how old prices are",
		"Add when Auctionator last saw each item, like \"updated 2h ago\" or \"updated 3 days ago\". TSM doesn't tell other addons how old its prices are, so TSM answers don't get one.")
	checkbox("vendorPrice", "Mention vendor price",
		"When an item has no auction price, say what a vendor pays for it instead.")

	Settings.RegisterAddOnCategory(category)
end
