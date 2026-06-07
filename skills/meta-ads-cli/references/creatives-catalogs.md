# Ad Creatives, Datasets & Catalogs — Detailed Workflows

## Ad creatives

Every creative requires `--page-id` (the Business Page that acts as the ad's
identity). Find it with `meta ads page list`. The CLI picks the format from the
flags you pass:
- `--video` present → **video ad**
- `--link-url` present (no video) → **link ad**
- neither → **photo post**

Common flags: `--name` (req), `--page-id` (req), `--image` OR `--video`, `--body`,
`--title`, `--link-url`, `--description`, `--call-to-action`, `--instagram-actor-id`.

Supported media — images: .jpg .jpeg .png .gif .bmp .webp · videos: .mp4 .mov .avi .mkv .wmv (uploaded automatically).

Call-to-action values: `APPLY_NOW`, `BOOK_TRAVEL`, `BUY_NOW`, `CONTACT_US`,
`DOWNLOAD`, `GET_OFFER`, `GET_QUOTE`, `LEARN_MORE`, `NO_BUTTON`, `OPEN_LINK`,
`SHOP_NOW`, `SIGN_UP`, `SUBSCRIBE`, `WATCH_MORE`.

```bash
# Link ad
meta ads creative create --name "Summer Sale" --image ./banner.jpg \
  --page-id <PAGE_ID> --body "50% off everything!" \
  --link-url https://example.com --title "Shop Now" --call-to-action SHOP_NOW

# Video ad
meta ads creative create --name "Video Promo" --page-id <PAGE_ID> \
  --video ./promo.mp4 --body "Watch our new collection" \
  --title "New Arrivals" --link-url https://example.com/new

# Photo post (no link)
meta ads creative create --name "Page Post" --page-id <PAGE_ID> \
  --image ./photo.jpg --body "Check out our latest product!"
```

Add Instagram placements with `--instagram-actor-id <INSTAGRAM_ACCOUNT_ID>`.

### Dynamic Creative Optimization (DCO)
Plural flags let Meta auto-test combinations. Requires `--link-url` plus at least
one `--images` or `--videos`. Limits: images 10, videos 10, titles 5, bodies 5,
descriptions 5, call-to-actions 5.

```bash
meta ads creative create --name "DCO Test" --page-id <PAGE_ID> \
  --link-url https://example.com \
  --images ./img1.jpg --images ./img2.jpg --images ./img3.jpg \
  --titles "Shop Now" --titles "Learn More" \
  --bodies "50% off everything!" --bodies "Free shipping today!" \
  --descriptions "Limited time offer" --descriptions "While supplies last" \
  --call-to-actions SHOP_NOW --call-to-actions LEARN_MORE
```

## End-to-end: creative → live ad

```bash
meta ads page list                                   # 1. find Business Page ID
meta ads creative create --name "Launch Ad" --page-id <PAGE_ID> \
  --image ./launch-banner.jpg --body "Our new product is here!" \
  --title "Just Launched" --link-url https://example.com/launch \
  --call-to-action SHOP_NOW                           # 2. create creative
meta ads ad create <AD_SET_ID> --name "Launch Ad - US" \
  --creative-id <CREATIVE_ID>                         # 3. create ad (PAUSED)
meta ads ad update <AD_ID> --status ACTIVE            # 4. go live (spends money)
```

## Datasets (Pixels) & catalogs

A dataset is a Meta Pixel / Conversions API endpoint. Business ID resolves in
order: `--business-id` flag → `BUSINESS_ID` env → derived from ad account → prompt.
A business admin must accept Meta business-tools terms before creating a dataset;
the creator is auto-granted ADVERTISE/ANALYZE/EDIT.

```bash
meta ads dataset create --name "Website Pixel"
meta ads dataset connect <PIXEL_ID> --ad-account-id <AD_ACCOUNT_ID>
meta ads dataset connect <PIXEL_ID> --catalog-id <CATALOG_ID>
meta ads dataset disconnect <PIXEL_ID> --ad-account-id <AD_ACCOUNT_ID> --force
meta ads dataset assign-user <PIXEL_ID> --tasks ADVERTISE --tasks ANALYZE --tasks EDIT
```

### End-to-end: conversion tracking

```bash
meta ads dataset create --name "Website Pixel"                       # -> <PIXEL_ID>
meta ads dataset connect <PIXEL_ID> --ad-account-id <AD_ACCOUNT_ID>
meta ads dataset connect <PIXEL_ID> --catalog-id <CATALOG_ID>        # optional
meta ads campaign create --name "Sales Campaign" --objective OUTCOME_SALES
meta ads adset create <CAMPAIGN_ID> --name "Purchase Optimization" \
  --optimization-goal OFFSITE_CONVERSIONS --billing-event IMPRESSIONS \
  --pixel-id <PIXEL_ID> --custom-event-type PURCHASE --targeting-countries US
meta ads creative create --name "Product Ad" --page-id <PAGE_ID> \
  --image ./product.jpg --body "Buy now!" --link-url https://example.com \
  --call-to-action SHOP_NOW
meta ads ad create <AD_SET_ID> --name "Product Ad" \
  --creative-id <CREATIVE_ID> --pixel-id <PIXEL_ID>
```

## Cleanup (deletes cascade; --force skips confirm)

```bash
meta ads ad delete <AD_ID> --force
meta ads adset delete <AD_SET_ID> --force
meta ads campaign delete <CAMPAIGN_ID> --force
meta ads creative delete <CREATIVE_ID> --force
meta ads dataset disconnect <PIXEL_ID> --ad-account-id <AD_ACCOUNT_ID> --force
meta ads catalog delete <CATALOG_ID> --force
```
