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

A guild mate wants to know what something sells for. PriceCheck Reply answers them with your **TSM or Auctionator** price, so you don't have to stop what you're doing to look it up.

They type `?pc` with an item link, or just `?` the old-school way, and get this back:
`[Linen Cloth]: 25s 30c (TSM market value)`

### Ask any way you like
- **Old-school style:** `?[Linen Cloth]` works too. A question mark in normal chat, like `anyone have [Linen Cloth]?`, doesn't count.
- **Stacks:** `?pc 20 [Linen Cloth]` answers with the price of 20 and of one.
- **Several items** in one message.
- **Their choice of price:** `?pc tsm [item]` or `?pc auc [item]` picks the price addon. If you only have one of them, the answer says so.
- **Battle pets** work too.

### Honest answers
- **Items that can't be auctioned** say so instead of getting a price: `binds when picked up, can't be auctioned, sells to a vendor for 5s`. Quest items and account-bound items too.
- **No price yet?** The answer says there's no auction data, plus what a vendor pays.
- **How fresh is it?** Auctionator prices say when they were updated: `updated 2h ago`.

### You choose who gets answered
Whispers from friends, Battle.net friends and guild mates are answered from the start. Turn on strangers, or guild, officer, party and raid chat. For each chat, answer right there so everyone sees the price, or whisper the asker.

### One answer, even in a big guild
When several guild mates have PriceCheck Reply, a request still gets **just one answer**, and who answers changes from request to request. No flooded guild chat.

### Polite by design
- It never answers your own messages or Game Masters.
- The same answer isn't repeated within a few seconds, and a flood of requests won't get you muted for spam.

### Good to know
- Needs **TradeSkillMaster** or **Auctionator** with prices for your realm.
- Made for **WoW Forever**.
- **/pricereply** opens the options. **/pricereply test [item]** shows the answer you'd send, only to you.

**Feedback and bug reports are welcome** in the comments.
```
---

**Source / Issues links:** `https://github.com/Archydude/PriceCheckReply` and `https://github.com/Archydude/PriceCheckReply/issues`

## B. Upload File form

**File:** `dist\PriceCheckReply-1.0.0.zip`

**Display name**
```
PriceCheck Reply 1.0.0
```

**Release type:** `Release`

**Game versions:** WoW Forever `1.60.1`.

**Changelog** (paste only the newest part; paste older parts too if they never went up)
```markdown
1.0.0
- First release: when a friend or guild mate whispers you `?pc` with an item link, they get the item's price back from TSM or Auctionator, like `[Linen Cloth]: 25s 30c (TSM market value)`.
- Ask about several items at once, or about a stack: `?pc 20 [Linen Cloth]` answers with the price of 20 and the price of one.
- Auctionator prices say how old they are, like `(Auctionator, updated 2h ago)`.
- Items that can't be sold on the auction house, like ones that bind when picked up, quest items and warbound items, are answered with that instead of a price, plus what a vendor pays.
- Askers can pick the price addon: `?pc tsm [Linen Cloth]` or `?pc auc [Linen Cloth]`.
- Choose who gets answered: friends, Battle.net friends, guild mates or anyone. Requests in guild, officer, party and raid chat can be answered in the same chat or by whispering the asker. When several of you in that chat have the addon, only one of you answers each request.
- Pick which TSM price to answer with.
- `/pricereply test` with an item link shows the answer you'd send, only to you.
```
