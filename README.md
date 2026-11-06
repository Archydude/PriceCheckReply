# PriceCheck Reply

Answers price questions for you. When a friend or guild mate whispers you `?pc` with an item link, PriceCheck Reply whispers back what the item goes for, using your TSM or Auctionator prices. You don't have to stop what you're doing to look it up.

```
Friend whispers: ?pc [Linen Cloth]
To Friend: [Linen Cloth]: 25s 30c (TSM market value)
```

Made for WoW Forever.

## Requirements

**TradeSkillMaster** or **Auctionator**, with prices for your realm. Without one of them it doesn't answer, and it tells you once when someone asks.

## Asking

- **One item:** `?pc [Linen Cloth]`
- **A stack:** `?pc 20 [Linen Cloth]`, `?pc 20x [Linen Cloth]` or `?pc [Linen Cloth] x20`. The answer gives the price of 20 and of one: `20x [Linen Cloth]: 5g 6s (25s 30c each, TSM market value)`
- **Several items:** `?pc [Linen Cloth] [Wool Cloth]`, up to 6 at once. Answers are put together into as few lines as fit.
- **Battle pets:** pet links work too.
- **A price addon of their choice:** `?pc tsm [Linen Cloth]` or `?pc auc [Linen Cloth]` (or `auctionator`) answers with that addon's price, and the answer always says which addon it's from. If you don't have the addon they asked for, the answer comes from the one you have and says so: `(Auctionator, no TSM here)`. You can turn this off.

`?pc` can be anywhere in the message, in upper or lower case, but it has to stand on its own (`?pcs` doesn't count), and item names don't count. It can't be changed, so everyone asks the same way.

Items with no auction price get `no auction data` back, plus what a vendor pays for them when the game knows (you can turn that off).

Items that can't go on the auction house say so instead of getting a price: `[Bound Sword]: binds when picked up, can't be auctioned, sells to a vendor for 5s`. That covers items that bind when picked up, quest items and items bound to your account. An item the game hasn't seen yet can take a moment to answer.

## Who gets answered

Whispers are always answered with a whisper:

| Option | Default | |
|---|---|---|
| Whispers from friends | On | Your friends list and your Battle.net friends' characters |
| Whispers from guild mates | On | |
| Whispers from anyone | Off | Strangers too |
| Battle.net whispers | On | Answered by Battle.net whisper |

For requests in a chat channel, you choose for each one: **Don't answer** (the default), **Answer in the same chat** so everyone there sees the price, or **Whisper the asker** to keep it between the two of you.

| Option | Covers |
|---|---|
| Guild chat | Guild chat |
| Officer chat | Officer chat |
| Party and raid chat | Party, raid and instance chat |

**When several of you have PriceCheck Reply**, a request in guild, officer, party or raid chat still gets just one answer, about a second later, instead of one from everyone. Who answers changes from request to request. Someone who has that chat set to Don't answer is left out, so one of the others answers. Whispers are answered right away, since only you got them.

Where the game hides chat from addons, such as during some fights, nothing gets answered there.

To keep chat tidy, the same answer isn't sent to the same place twice within a few seconds, and a sudden flood of requests only gets some answers, so you don't get muted for spam. It never answers your own messages or Game Masters.

## Prices

- **Price addon:** Automatic (TSM, and Auctionator for items TSM has no price for), TSM only, or Auctionator only. Askers who add `tsm` or `auc` to their request get that addon instead.
- **Askers can pick the price addon:** on by default.
- **TSM price:** market value (default), lowest auction right now, historical price, or region market average.
- **Say where prices come from:** adds `(TSM market value)` or `(Auctionator)` to each answer.
- **Say how old prices are:** adds when Auctionator last saw the item: `updated 2h ago` for an item seen in today's scan, `updated today` when Auctionator can't say more, then `updated yesterday` or `updated 5 days ago`. TSM doesn't tell other addons how old its prices are, so TSM answers don't get one. On by default.
- **Mention vendor price:** for items with no auction price.

## Commands

- `/pricereply` opens the options (also Esc > Options > AddOns > PriceCheck Reply). `/pcreply` works too.
- `/pricereply on` and `/pricereply off` turn answering on and off.
- `/pricereply test [item link]` shows the answer you'd send, only to you. Shift-click an item to put its link in. Add `tsm` or `auc` to see what an asker picking that addon would get.

## License

MIT, see [LICENSE](LICENSE).
