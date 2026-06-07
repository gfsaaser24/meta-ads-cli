# Generating a Meta System User Access Token

Use this when the user does not yet have a token. The CLI authenticates as a
**Meta admin system user** — a non-human account that owns API access.

## Requirements
- A Meta Business Suite account with admin rights.
- A Meta app (developers.facebook.com).
- The ad account, Page(s), pixel(s)/dataset(s), and catalog(s) you want to manage.

## Steps

1. **Create an admin system user.**
   Meta Business Suite → Settings → Users → System Users → Add. Give it the
   **Admin** role.

2. **Assign assets to the system user.**
   Still in System Users, assign the ad account(s), Business Page(s),
   dataset(s)/pixel(s), and product catalog(s) it should control, with full
   (manage) permissions.

3. **Add the system user as an App Admin.**
   Meta for Developers → your app → App Settings → Roles → Roles → add the system
   user as an Admin of the app.

4. **Generate the token with the right scopes.**
   In System Users, click Generate New Token, pick the app, and select these
   permissions:
   `business_management`, `ads_management`, `pages_show_list`,
   `pages_read_engagement`, `pages_manage_ads`, `catalog_management`,
   `read_insights`.
   Copy the token immediately — it is shown once.

## Store it for the CLI

```bash
cat > .env << 'DOTENV'
ACCESS_TOKEN='<the generated token>'
AD_ACCOUNT_ID='act_<ad account id>'
# BUSINESS_ID='<id>'   # add if working with catalogs/datasets
DOTENV

meta auth status         # masked token confirms it loaded
meta ads adaccount list  # confirms it works and shows valid act_ IDs
```

Security: the token grants full ad-management power over those assets. Don't print
it in full, don't commit it, and don't store it in long-term memory. The sandbox
`.env` is wiped at session end; to persist, save the `.env` in the user's
connected workspace folder.
