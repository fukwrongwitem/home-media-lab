# Jellyfin access model

Dual-use home stack: one owner admin account plus a household account with limited powers.

## Accounts (pattern)

| Role | Jellyfin | Intent |
|------|----------|--------|
| Owner | admin user | Stack admin, library and plugin management |
| Household | non-admin user | Watch only; no dashboard, no library edits, no deletes |

In this lab there is one owner account and one household account. A duplicate owner account I created by mistake has been **removed**.

## Policy

- New users default to non-admin, with "Allow media deletion" off.

## Passwords

Not stored in this repo. Users change passwords in Jellyfin (Profile → Password).

## Ops notes

- After creating users, check Dashboard → Users that admin vs non-admin matches the table above.
- Keep credentials out of notes that sync toward public docs.
