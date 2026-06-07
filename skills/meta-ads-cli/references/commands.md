# Meta Ads CLI — Command Reference

Syntax: `meta [global options] ads <resource> <action> [options]`.
Conventions: `<UPPER_CASE>` = placeholder you fill in; `[optional]`; `--flag` = named option.
**All budgets and bid amounts are in cents** (5000 = $50.00).

## Global options (place before the resource)

| Option | Short | Description |
| --- | --- | --- |
| `--output <table\|json\|plain>` | `-o` | Output format (default `table`). |
| `--no-color` | | Disable colored output. |
| `--no-input` | | Disable interactive prompts (for scripts). |
| `--debug` | | Show underlying API errors. |
| `--version` | `-v` | Print version. |
| `--help` | `-h` | Help for any command/subcommand. |

`meta ads` also accepts `--ad-account-id act_123` and `--business-id <id>` (override env/.env per call).

```bash
meta -o json ads campaign list | jq '.[].name'
meta -o plain ads campaign list | sort -t$'\t' -k5 -rn
```

## Authentication
- `meta auth status` — check auth; prints a masked token. Token is supplied via `.env` (`ACCESS_TOKEN=`) or `export ACCESS_TOKEN=`.

## Ad accounts & pages
- `meta ads adaccount list [--limit N]` — columns: id, name, account_status, currency, timezone_name.
- `meta ads adaccount current` — show currently configured ad account ID.
- `meta ads page list [--limit N]` — columns: id, name, category. Use these IDs with `--page-id` on creatives.

## Campaigns
- `meta ads campaign list [--limit N]` (default 10).
- `meta ads campaign create --name "..." --objective <OBJ> [--daily-budget CENTS] [--lifetime-budget CENTS] [--status PAUSED|ACTIVE]`
  - `--status` default `PAUSED`. Objectives: `OUTCOME_APP_PROMOTION`, `OUTCOME_AWARENESS`, `OUTCOME_ENGAGEMENT`, `OUTCOME_LEADS`, `OUTCOME_SALES`, `OUTCOME_TRAFFIC`.
- `meta ads campaign get <CAMPAIGN_ID>`
- `meta ads campaign update <CAMPAIGN_ID> [--name] [--status ACTIVE|PAUSED|ARCHIVED] [--daily-budget] [--lifetime-budget]` (≥1 option required)
- `meta ads campaign delete <CAMPAIGN_ID> [--force]` (cascades to ad sets + ads)

```bash
meta ads campaign create --name "Sales Campaign" --objective OUTCOME_SALES --daily-budget 5000
```

## Ad sets
- `meta ads adset list [<CAMPAIGN_ID>] [--limit N]`
- `meta ads adset create <CAMPAIGN_ID> --name "..." --optimization-goal <GOAL> --billing-event <EVENT> [options]`
  - Options: `--daily-budget CENTS` (omit under campaign budget optimization), `--lifetime-budget CENTS` (requires `--end-time`), `--bid-amount CENTS`, `--start-time` ISO8601, `--end-time` ISO8601, `--status` (default PAUSED), `--targeting-countries US,CA,GB`, `--pixel-id`, `--custom-event-type` (default PURCHASE).
  - Optimization goals: `APP_INSTALLS`, `CONVERSATIONS`, `EVENT_RESPONSES`, `IMPRESSIONS`, `LANDING_PAGE_VIEWS`, `LEAD_GENERATION`, `LINK_CLICKS`, `OFFSITE_CONVERSIONS`, `PAGE_LIKES`, `POST_ENGAGEMENT`, `REACH`, `THRUPLAY`, `VALUE`.
  - Billing events: `APP_INSTALLS`, `CLICKS`, `IMPRESSIONS`, `LINK_CLICKS`, `PAGE_LIKES`, `POST_ENGAGEMENT`, `THRUPLAY`.
  - Custom event types: `ADD_PAYMENT_INFO`, `ADD_TO_CART`, `ADD_TO_WISHLIST`, `COMPLETE_REGISTRATION`, `CONTACT`, `CONTENT_VIEW`, `CUSTOMIZE_PRODUCT`, `DONATE`, `FIND_LOCATION`, `INITIATED_CHECKOUT`, `LEAD`, `OTHER`, `PURCHASE`, `SCHEDULE`, `SEARCH`, `START_TRIAL`, `SUBMIT_APPLICATION`, `SUBSCRIBE`.
- `meta ads adset get <AD_SET_ID>`
- `meta ads adset update <AD_SET_ID> [--name] [--status ACTIVE|PAUSED|ARCHIVED] [--daily-budget] [--lifetime-budget] [--bid-amount] [--end-time]` (≥1 required)
- `meta ads adset delete <AD_SET_ID> [--force]` (cascades to ads)

```bash
meta ads adset create <CAMPAIGN_ID> --name "Conversions Set" \
  --optimization-goal OFFSITE_CONVERSIONS --billing-event IMPRESSIONS \
  --pixel-id <PIXEL_ID> --custom-event-type PURCHASE --targeting-countries US
```

## Ads
- `meta ads ad list [<AD_SET_ID>] [--limit N]`
- `meta ads ad create <AD_SET_ID> --name "..." --creative-id <CREATIVE_ID> [--status] [--pixel-id | --tracking-specs JSON]`
  - Use `--pixel-id` OR `--tracking-specs`, not both. Default status PAUSED.
- `meta ads ad get <AD_ID>`
- `meta ads ad update <AD_ID> [--name] [--creative-id] [--status ACTIVE|PAUSED|ARCHIVED]` (≥1 required)
- `meta ads ad delete <AD_ID> [--force]`

## Creatives
See `creatives-catalogs.md` for full detail.
- `meta ads creative list [--limit N]`
- `meta ads creative create --name "..." --page-id <PAGE_ID> [media + copy flags]`
- `meta ads creative get <CREATIVE_ID>`
- `meta ads creative update <CREATIVE_ID> [...]`
- `meta ads creative delete <CREATIVE_ID> [--force]` (can't delete if used by an active ad)

## Datasets (Meta Pixels)
- `meta ads dataset list [--business-id] [--limit N]`
- `meta ads dataset get <PIXEL_ID>`
- `meta ads dataset create --name "..." [--business-id]`
- `meta ads dataset connect <PIXEL_ID> [--ad-account-id] [--catalog-id]` (≥1 of the two)
- `meta ads dataset disconnect <PIXEL_ID> --ad-account-id <ID> [--force]`
- `meta ads dataset assign-user <PIXEL_ID> [--user-id] [--tasks ADVERTISE --tasks ANALYZE ...]` (tasks: ADVERTISE, ANALYZE, EDIT, UPLOAD)

## Product catalogs
- `meta ads catalog list [--business-id] [--limit N]`
- `meta ads catalog get <CATALOG_ID>`
- `meta ads catalog create --name "..." [--vertical commerce]`
  - Verticals: `adoptable_pets`, `commerce`, `destinations`, `flights`, `generic`, `home_listings`, `hotels`, `local_service_businesses`, `offer_items`, `offline_commerce`, `transactable_items`, `vehicles`.
- `meta ads catalog update <CATALOG_ID> --name "..."`
- `meta ads catalog delete <CATALOG_ID> [--force]` (can't delete with active feeds/referencing ads)

## Catalog children
The CLI also exposes `meta ads product-feed`, `meta ads product-item`, and
`meta ads product-set` (each with `list`/`create`/`get`/`update`/`delete`) for
managing feeds, items, and product sets inside a catalog. Run
`meta ads product-feed --help` (etc.) for the exact flags, since these operate on
a `--catalog-id`.

## Insights
`meta ads insights get [...]` — see `insights.md`.

## Exit codes
0 success · 1 general error · 2 usage error · 3 auth error · 4 API error · 5 not found.
