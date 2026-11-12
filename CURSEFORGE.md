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
Friends and guild mates type ?pc or ? with an item link and get your TSM or Auctionator price back, with a total when they ask about several items.
```

**Main category:** `Auction & Economy`
**Additional categories:** `Chat & Communication`

**License:** `MIT License`

**Logo / avatar:** `PriceCheckReply\images\logo-v1.png`

**Description** (paste everything between the lines)

---
```markdown
## Price checks, answered for you

When a guild mate asks what something sells for, PriceCheck Reply answers with your **TSM or Auctionator** price, so you don't have to look it up.

They type `?pc [Linen Cloth]`, or just `?[Linen Cloth]`, and get this back:
`[Linen Cloth]: 25s 30c (TSM market value)`

### Ask any way you like
- **The short `?`:** a `?` right before the link asks, old-school style. `anyone have [Linen Cloth]?` doesn't count.
- **Stacks:** `?pc 20 [Linen Cloth]` or `?20 [Linen Cloth]` prices 20 and one.
- **Shopping lists:** several items, each with its own amount, get the **total first**, then each item:
  `Total: 3g 47s for 3 items (TSM market value)`
- **Their choice of price:** `?pc tsm [item]` or `?pc auc [item]` picks the price addon.
- **Battle pets** work too.

### Honest answers
- **Items that can't be auctioned** say so: `binds when picked up, can't be auctioned`.
- **No price yet?** It says so, plus what a vendor pays.
- **How fresh is it?** Auctionator prices say when they were updated: `updated 2h ago`.
- **Does it sell?** Optionally add TSM's region sale rate and daily sales: `region sale rate 94%, region sells 2,847/day`.

### You choose who gets answered
Whispers from friends, Battle.net friends and guild mates are answered from the start. Turn on strangers, or guild, officer, party and raid chat, answered right there or by whisper. On WoW Forever, guild and officer requests always get a whisper, since the realms don't let addons write there for now.

### When several of you have it
In party and raid chat, a request gets **just one answer**, and who answers changes from request to request. Guild and officer chat work the same where the realm lets addons write there. On WoW Forever it doesn't, so each of you whispers the asker.

### Polite by design
- It never answers your own messages or Game Masters.
- No repeats within a few seconds, and a flood of requests won't get you muted for spam.
- On Retail it stays quiet in dungeons, raids and battlegrounds, where the game hides chat from addons.

### Good to know
- Needs **TradeSkillMaster** or **Auctionator** with prices for your realm.
- Works on Retail, Mists of Pandaria Classic, TBC Anniversary, WoW Forever and Classic Era.
- **/pricereply** opens the options. **/pricereply test [item]** shows the answer you'd send, only to you.

**Feedback and bug reports are welcome** in the comments.
```
---

**Source / Issues links:** `https://github.com/Archydude/PriceCheckReply` and `https://github.com/Archydude/PriceCheckReply/issues`

## B. Upload File form

**File:** `dist\PriceCheckReply-1.2.0.zip`

**Display name**
```
PriceCheck Reply 1.2.0
```

**Release type:** `Release`

**Game versions:** Retail `12.1.0` and `12.1.5`, Mists of Pandaria Classic `5.5.4`, TBC Anniversary `2.5.5` and `2.5.6`, WoW Forever `1.60.1`, Classic Era `1.15.9` (covers Season of Discovery).

**Changelog** (paste only the newest part; paste older parts too if they never went up)
```markdown
1.2.0
- Ask about several items and get the total: `?100[Copper Bar] 100[Handful of Copper Bolts]` answers with the total first, `Total: 1g 95s for 2 items (TSM market value)`, then each item on its own. Items with no price are left out of the total, and it says so.
- New options: TSM's region sale rate and how many sell per day, added to each price, like `(region sale rate 94%, region sells 2,847/day)`. Off by default.
- Fixed: the lines of a long answer could reach the asker out of order.
```
