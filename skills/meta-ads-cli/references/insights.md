# Insights — `meta ads insights get`

Pulls performance data at account, campaign, ad set, or ad level. With no scope
flag it reports account-level for the last 30 days.

## Options

| Option | Description |
| --- | --- |
| `--date-preset <preset>` | Default `last_30d`. See presets below. |
| `--since YYYY-MM-DD` / `--until YYYY-MM-DD` | Custom range; use together; overrides `--date-preset`. |
| `--time-increment <all_days\|daily\|weekly\|monthly>` | Default `all_days`. |
| `--breakdown <dim>` | Repeatable; split rows by a dimension. |
| `--fields <a,b,c>` | Comma-separated metrics. |
| `--campaign-id <ID>` / `--adset-id <ID>` / `--ad-id <ID>` | Scope to one object. |
| `--sort <metric>_ascending\|<metric>_descending` | Sort rows. |
| `--limit N` / `-l` | Default 50. |

Date presets: `today`, `yesterday`, `last_3d`, `last_7d`, `last_14d`, `last_30d`,
`last_90d`, `this_month`, `last_month`.

Breakdowns: `age`, `gender`, `country`, `publisher_platform`, `device_platform`,
`platform_position`, `impression_device`.

Default fields: `spend`, `impressions`, `clicks`, `ctr`, `cpc`, `reach`. Any valid
Meta Insights API field works; common ones: `spend`, `impressions`, `reach`,
`clicks`, `ctr`, `cpc`, `cpm`, `frequency`, `conversions`, `cost_per_conversion`,
`purchase_roas`.

## Examples

```bash
meta ads insights get                                                  # account, last 30d
meta ads insights get --date-preset yesterday
meta ads insights get --since 2026-01-01 --until 2026-01-31
meta ads insights get --campaign-id <CAMPAIGN_ID> --time-increment weekly
meta ads insights get --adset-id <AD_SET_ID> --fields spend,impressions,ctr,cpc
meta ads insights get --breakdown age --breakdown gender
meta ads insights get --breakdown publisher_platform --fields spend,impressions,ctr
meta ads insights get --adset-id <AD_SET_ID> --sort spend_descending
meta ads insights get --fields spend,conversions,cost_per_conversion,purchase_roas

# Per-campaign ROAS loop
for id in $(meta -o json ads campaign list | jq -r '.[].id'); do
  echo "Campaign $id"
  meta ads insights get --campaign-id "$id" --fields conversions,purchase_roas
done
```
