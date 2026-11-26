# PriceCheck Reply: CurseForge upload sheet

What to type into each CurseForge field, ready to copy and paste. The steps for a first upload and for releasing an update are in [UPLOADING.md](../UPLOADING.md).

Update this sheet with every release: the zip, the display name and the changelog, and rewrite the description so it covers everything in the new version.

## A. Project form

**Project name**
```
PriceCheck Reply
```

**Summary**
```
Friends and guild mates type ?pc or ? with an item link and get your TSM, Auctionator or Craftonomics price back, with a total when they ask about several items.
```

**Main category:** `Auction & Economy`
**Additional categories:** `Chat & Communication`

**License:** `MIT License`

**Logo / avatar:** `PriceCheckReply\images\logo-v2.png`

**Description** (paste everything between the lines)

---
```markdown
## Price checks, answered for you

When a guild mate asks what something sells for, PriceCheck Reply answers with your **TSM, Auctionator or Craftonomics** price, so you don't have to look it up.

They type `?pc [Linen Cloth]`, or just `?[Linen Cloth]`, and get this back:
`[Linen Cloth]: 25s 30c (TSM market)`

### Ask any way you like
- **The short `?`:** a `?` right before the link asks, old-school style. `anyone have [Linen Cloth]?` doesn't count.
- **Stacks:** `?pc 20 [Linen Cloth]` or `?20 [Linen Cloth]` prices 20 and one.
- **Several items:** up to 6 in one message, each with its own amount. The answer starts with the **total**, then lists each item.
- **Source & net price:** `?pc tsm [item]`, `?pc auc [item]` or `?pc craft [item]` picks the addon; `?pc net [item]` deducts the 5% AH cut.
- **Battle pets** work too.

### Honest answers
- **Items that can't be auctioned** say so: `binds when picked up, can't be auctioned`.
- **No price yet?** It says so, plus what a vendor pays.
- **Above or below value?** Optionally add a second TSM price: `(TSM market, lowest 22s)`.
- **How fresh is it?** Auctionator prices say when they were updated: `updated 2h ago`.
- **Does it sell?** Optionally add TSM's region sale rate and daily sales.

### You choose who gets answered
Whispers from friends, Battle.net friends and guild mates are answered from the start. Turn on strangers, or requests made in guild, officer, party and raid chat. In party and raid chat, a request gets **just one answer** when several of you have the addon. Guild and officer requests are answered by whisper, since the game doesn't let addons write there.

### Polite by design
- It never answers Game Masters, and won't repeat itself or get you muted for spam.
- On Retail it stays quiet in dungeons, raids and battlegrounds, where the game hides chat from addons.

### Good to know
- Needs **TradeSkillMaster**, **Auctionator** or **Craftonomics** with prices for your realm.
- Works on Retail, Mists of Pandaria Classic, TBC Anniversary, WoW Forever and Classic Era.
- **/pricereply** opens the options. **/pricereply selftest** lets you try it alone.

This addon was made with AI.

**Feedback, suggestions, and bug reports are welcome** in the comments or by sending me a message on Discord.
```
---

**Source / Issues links:** `https://github.com/Archydude/PriceCheckReply` and `https://github.com/Archydude/PriceCheckReply/issues`

## B. Upload File form

**File:** `dist\PriceCheckReply-1.4.2.zip`

**Display name**
```
PriceCheck Reply 1.4.2
```

**Release type:** `Release`

**Game versions:** Retail `12.1.0` and `12.1.5`, Mists of Pandaria Classic `5.5.4`, TBC Anniversary `2.5.5` and `2.5.6`, WoW Forever `1.60.1`, Classic Era `1.15.9` (covers Season of Discovery).

**Changelog** (paste only the newest part; paste older parts too if they never went up)
```markdown
1.4.2
- Fixed: stays quietly out of the way in Retail dungeons, raids and battlegrounds when the game hides chat from addons, without errors or unnecessary background work.

1.4.1
- Fixed: numbers in chat like `tier 2 [Item]`, `r3 [Item]` or `+10 [Item]` are no longer mistaken for an item quantity.
- Fixed: account-bound, Warbound, and Warbound until equipped items are accurately reported as non-auctionable.

1.4.0
- **Craftonomics prices:** PriceCheck Reply can now answer with prices from **Craftonomics** (as a fallback in Automatic mode, as **Craftonomics only**, or when someone asks with `?pc craft [item]`).
- **Net after AH cut:** asking with `?pc net [item]` deducts the 5% auction house cut and notes `(after 5% cut)` on single items and multi-item totals.
- Fixed: a bare `?pc` with no item link is ignored, your own messages are recognized reliably on WoW Forever, Auctionator price ages still show when looked up by item ID, and multi-line replies stop cleanly if chat becomes restricted mid-reply.

1.3.0
- New option, Also say: a second TSM price next to the main one, like `(TSM market, lowest 22s)`, so the asker can tell whether today's price is above or below its usual value. For a stack it's the price of one; several items get both totals. Off by default.
- Price names in answers are shorter: `TSM market`, `TSM lowest` and `TSM region avg`.
- Guild chat and officer chat are now on/off options, Answer guild chat by whisper and Answer officer chat by whisper. The game doesn't let addons write in those chats, on Retail as well as WoW Forever, so those answers were already whispers; now the options say so. If you had either chat answered, it stays on.
- New `/pricereply selftest`: for 5 minutes your own requests in chat get answered like anyone else's, so you can try it alone.

1.2.2
- Fixed: after you opened PriceCheck Reply's options, the game's own options could show the error "AddOn 'PriceCheckReply' tried to call the protected function 'IsUserOAuthed()'".

1.2.1
- Fixed an error when opening the options during combat ("tried to call the protected function 'OpenSettingsPanel()'"). The options now open as soon as the fight ends.

1.2.0
- Ask about several items and get the total: `?100[Copper Bar] 100[Handful of Copper Bolts]` answers with the total first, `Total: 1g 95s for 2 items (TSM market value)`, then each item on its own. Items with no price are left out of the total, and it says so.
- New options: TSM's region sale rate and how many sell per day, added to each price, like `(region sale rate 94%, region sells 2,847/day)`. Off by default.
- Fixed: the lines of a long answer could reach the asker out of order.
```
