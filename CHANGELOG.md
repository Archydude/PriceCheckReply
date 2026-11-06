# Changelog

## 1.0.0
- First release: when a friend or guild mate whispers you `?pc` with an item link, they get the item's price back from TSM or Auctionator, like `[Linen Cloth]: 25s 30c (TSM market value)`.
- Ask about several items at once, or about a stack: `?pc 20 [Linen Cloth]` answers with the price of 20 and the price of one.
- Auctionator prices say how old they are, like `(Auctionator, updated 2h ago)`.
- Items that can't be sold on the auction house, like ones that bind when picked up, quest items and warbound items, are answered with that instead of a price, plus what a vendor pays.
- Askers can pick the price addon: `?pc tsm [Linen Cloth]` or `?pc auc [Linen Cloth]`.
- Choose who gets answered: friends, Battle.net friends, guild mates or anyone. Requests in guild, officer, party and raid chat can be answered in the same chat or by whispering the asker. When several of you in that chat have the addon, only one of you answers each request.
- Pick which TSM price to answer with.
- `/pricereply test` with an item link shows the answer you'd send, only to you.
