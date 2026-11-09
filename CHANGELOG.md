# Changelog

## 1.1.2
- Fixed: on WoW Forever, guild, officer, party and raid requests caused an "action blocked" error and got no answer. Forever's realms don't let addons write in chat, so on realms like that those requests are now answered by whisper. Each player there with the addon whispers the asker, since the addons can't agree on one answerer. Where the realm allows addon chat, nothing changes.

## 1.1.1
- Works on every version of WoW again: Retail, Mists of Pandaria Classic, TBC Anniversary, WoW Forever and Classic Era.

## 1.1.0
- The old-school way of asking works too: `?[Linen Cloth]`, a question mark right before the item link. Everyone with the addon answers it, and a question mark in normal chat, like `anyone have [Linen Cloth]?`, doesn't count.
- More ways to ask about a stack: `?x20 [Linen Cloth]`, `20 ?[Linen Cloth]`, and a plain number at the end of the message, like `?pc [Linen Cloth] 20`.

## 1.0.0
- First release: when a friend or guild mate whispers you `?pc` with an item link, they get the item's price back from TSM or Auctionator, like `[Linen Cloth]: 25s 30c (TSM market value)`.
- Ask about several items at once, or about a stack: `?pc 20 [Linen Cloth]` answers with the price of 20 and the price of one.
- Auctionator prices say how old they are, like `(Auctionator, updated 2h ago)`.
- Items that can't be sold on the auction house, like ones that bind when picked up, quest items and warbound items, are answered with that instead of a price, plus what a vendor pays.
- Askers can pick the price addon: `?pc tsm [Linen Cloth]` or `?pc auc [Linen Cloth]`.
- Choose who gets answered: friends, Battle.net friends, guild mates or anyone. Requests in guild, officer, party and raid chat can be answered in the same chat or by whispering the asker. When several of you in that chat have the addon, only one of you answers each request.
- Pick which TSM price to answer with.
- `/pricereply test` with an item link shows the answer you'd send, only to you.
