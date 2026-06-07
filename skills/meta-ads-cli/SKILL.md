---
name: meta-ads-cli
description: >-
  Run the Meta (Facebook/Instagram) Ads CLI — the `meta` command from the
  `meta-ads` Python package — inside Cowork's sandbox to manage Meta advertising
  from the terminal. Use this skill whenever the user wants to install or run the
  Meta Ads CLI / Facebook Ads CLI / the `meta` command, or asks to list, create,
  update, or delete Meta/Facebook ad campaigns, ad sets, ads, or ad creatives;
  pull ad performance insights or reporting (spend, ROAS, CTR, CPC, conversions)
  from the command line; or manage Meta pixels/datasets, product catalogs,
  product feeds, product sets, ad accounts, or Facebook Pages via CLI. Trigger
  this even when the user does not name the package — phrases like "set up the
  Meta ads CLI", "create a Facebook campaign from the terminal", "pull my Meta ad
  insights", or "spin up an Advantage+ sales campaign with the meta command" all
  apply. For pulling existing ad metrics where a Meta Ads MCP/connector is already
  attached, that connector may be simpler; this skill is for the standalone CLI.
---

# Meta Ads CLI

> Unofficial skill — not affiliated with or maintained by Meta. Written from Meta's
> published Ads CLI developer docs and the third-party `meta-ads` package. Verify flags
> against the official docs before any spend-affecting command, as they may drift.

The `meta` command (PyPI package `meta-ads`) is a developer-friendly wrapper over
the Meta Marketing API. It manages the full ad stack — campaigns, ad sets, ads,
creatives, pixels/datasets, catalogs, product feeds/sets — and queries insights,
all from the terminal. Commands follow a **noun-verb** pattern:

```
meta ads <resource> <action> [options]
```

Work through the three steps below in order: **install → authenticate → run**.
Detailed command syntax lives in the reference files; load them as needed rather
than guessing flags.

## Step 1 — Install the CLI in the sandbox

`meta-ads` needs Python 3.12+, which the Cowork sandbox usually lacks, so a bundled
script provisions it with `uv` and installs the CLI in isolation. Run it once per
session:

```bash
bash <skill_dir>/scripts/setup_meta_cli.sh
```

The script is idempotent and prints its install location on the last line as
`META_BIN=<dir>`. Capture that directory — each bash call starts fresh with no
PATH carried over, so **prepend `META_BIN` to PATH in every later command that
runs `meta`**:

```bash
export PATH="<META_BIN>:$PATH"
meta --version
```

If the script reports it needs `uv` or Python 3.12+, that environment can't run
the CLI; tell the user rather than improvising another install path.

The setup script and `meta` commands are bash-based. On **Windows**, run them inside
**WSL** (Windows Subsystem for Linux) — if the user is on a native Windows shell with
no WSL/bash available, tell them to install WSL first rather than trying to adapt the
commands to PowerShell/cmd.

## Step 2 — Authenticate

The CLI authenticates with a **Meta system user access token** and targets one
**ad account ID**. There is no interactive login.

Ask the user for their token and ad account ID, then write them to a `.env` in the
working directory and verify:

```bash
cat > .env << 'DOTENV'
ACCESS_TOKEN='<paste the user's token>'
AD_ACCOUNT_ID='act_<their ad account id>'
DOTENV

export PATH="<META_BIN>:$PATH"
meta auth status            # shows a masked token if it loaded
meta ads adaccount list     # confirms the token actually works
```

Notes that save back-and-forth:
- `AD_ACCOUNT_ID` must be the `act_...` form. `meta ads adaccount list` shows valid IDs.
- Add `BUSINESS_ID='<id>'` to `.env` if the user works with catalogs/datasets and it isn't auto-resolved.
- The sandbox `.env` is **ephemeral** — it disappears when the session ends. If the
  user wants their token to persist, offer to save the `.env` into their connected
  workspace folder and load it from there next time. Treat the token as a secret:
  don't echo it back in full or write it to memory.
- The CLI reads config in this precedence: command-line flags → shell env vars →
  project `.env` → user config (`~/.config/meta/`).

If the user hasn't generated a token yet, walk them through it using
`references/setup-and-auth.md` (system user, asset assignment, required scopes).

## Step 3 — Run commands

Global options go **before** the resource, e.g. `meta -o json ads campaign list`.
Output formats: `table` (default, human-readable), `json` (pipe to `jq`), `plain`
(tab-separated for shell pipelines). Use `--no-input` and `--force` for
non-interactive runs.

```bash
export PATH="<META_BIN>:$PATH"
meta ads campaign list
meta -o json ads campaign list | jq '.[].name'
meta ads insights get --date-preset last_7d --fields spend,impressions,ctr,cpc
```

Pick the matching reference file for exact syntax, required flags, and enum values
before composing a command:

- `references/commands.md` — every resource and action (campaign, adset, ad,
  creative, adaccount, page, dataset, catalog, product-feed/-item/-set), with
  required flags, enums (objectives, optimization goals, billing events, custom
  event types, verticals, dataset tasks), budgets-in-cents rule, and exit codes.
- `references/creatives-catalogs.md` — building ad creatives (standard, video,
  photo, Instagram, Dynamic Creative), supported media types, call-to-action
  values, and the end-to-end creative→ad, conversion-tracking, and catalog/dataset
  workflows.
- `references/insights.md` — `meta ads insights get` in full: date presets,
  custom ranges, time increments, breakdowns, sortable metrics, common fields.
- `references/setup-and-auth.md` — generating the system user token (scopes,
  asset assignment) for users who don't have one yet.

## Things to keep in mind

- **Budgets are in cents.** `--daily-budget 5000` means $50.00. Always confirm the
  figure with the user in dollars before running, since a typo spends real money.
- **New objects are created `PAUSED` by default.** Nothing spends until you set
  status `ACTIVE` (e.g. `meta ads campaign update <ID> --status ACTIVE`). Activating
  a campaign, ad set, or ad starts real ad spend on the user's account — make sure
  the user means to go live.
- **Deletes cascade.** Deleting a campaign removes its ad sets and ads; deleting an
  ad set removes its ads. `--force` skips the confirmation prompt.
- **Exit codes** are meaningful for scripting: 0 success, 1 general error, 2 usage
  error, 3 auth error, 4 API error, 5 not found.
- When a command fails, run it again with the global `--debug` flag to see the
  underlying Marketing API error before changing the approach.
