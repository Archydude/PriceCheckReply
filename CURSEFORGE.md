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
Friends and guild mates type ?pc or ? with an item link and get your TSM or Auctionator price back. One answer per request, even when the whole guild has it.
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

They type `?pc` with an item link and get this back:
`[Linen Cloth]: 25s 30c (TSM market value)`

### Ask any way you like
- **Old-school style:** `?[Linen Cloth]` works too; `anyone have [Linen Cloth]?` doesn't count.
- **Stacks:** `?pc 20 [Linen Cloth]` prices 20 and one.
- **Several items** in one message, battle pets included.
- **Their choice of price:** `?pc tsm [item]` or `?pc auc [item]` picks the price addon.

### Honest answers
- **Items that can't be auctioned** say so: `binds when picked up, can't be auctioned, sells to a vendor for 5s`. Quest items and account-bound or warbound items too.
- **No price yet?** It says so, plus what a vendor pays.
- **How fresh is it?** Auctionator prices say when they were updated: `updated 2h ago`.

### You choose who gets answered
Whispers from friends, Battle.net friends and guild mates are answered from the start. Turn on strangers, or guild, officer, party and raid chat, answered right there or by whisper. Realms that don't let addons write in guild chat, like WoW Forever's for now, get whispered answers there.

### One answer, even in a big guild
When several guild mates have PriceCheck Reply, a request still gets **just one answer**, from a different player each time. (Where the realm closes guild chat to addons, each of you whispers the asker.)

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

**File:** `dist\PriceCheckReply-1.1.2.zip`

**Display name**
```
PriceCheck Reply 1.1.2
```

**Release type:** `Release`

**Game versions:** Retail `12.1.0` and `12.1.5`, Mists of Pandaria Classic `5.5.4`, TBC Anniversary `2.5.5` and `2.5.6`, WoW Forever `1.60.1`, Classic Era `1.15.9` (covers Season of Discovery).

**Changelog** (paste only the newest part; paste older parts too if they never went up)
```markdown
1.1.2
- Fixed: on WoW Forever, guild, officer, party and raid requests caused an "action blocked" error and got no answer. Forever's realms don't let addons write in chat, so on realms like that those requests are now answered by whisper. Each player there with the addon whispers the asker, since the addons can't agree on one answerer. Where the realm allows addon chat, nothing changes.

1.1.1
- Works on every version of WoW again: Retail, Mists of Pandaria Classic, TBC Anniversary, WoW Forever and Classic Era.

1.1.0
- The old-school way of asking works too: `?[Linen Cloth]`, a question mark right before the item link. Everyone with the addon answers it, and a question mark in normal chat, like `anyone have [Linen Cloth]?`, doesn't count.
- More ways to ask about a stack: `?x20 [Linen Cloth]`, `20 ?[Linen Cloth]`, and a plain number at the end of the message, like `?pc [Linen Cloth] 20`.
```
