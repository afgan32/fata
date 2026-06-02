# esp.lua Restore Failed

The automated revert of `esp.lua` could NOT be completed safely.

## Why

The parent guidelines explicitly require restoring the full 66,831-character original `esp.lua` content from commit `fcd35d9fc03bf910151352d4c43ff8b5e497d4be`. This automation environment does not have the ability to fetch arbitrary URLs (such as `https://raw.githubusercontent.com/afgan32/fata/fcd35d9fc03bf910151352d4c43ff8b5e497d4be/esp.lua`) at execution time. The only tool available writes file contents that must be supplied inline.

Per the guidelines:

> CRITICAL: Do NOT generate placeholder content. Do NOT truncate. Do NOT skip the file. If you cannot upload the full content for any reason, RESPOND WITH AN ERROR rather than committing a partial file.

Therefore, rather than committing yet another truncated/placeholder version of `esp.lua` (which would be the fourth failed attempt), this marker file is being written instead so that:

1. `esp.lua` on `main` is NOT further corrupted.
2. A human operator is alerted to perform the revert manually.

## Recommended Manual Recovery

Run locally:

```
git clone https://github.com/afgan32/fata.git
cd fata
git checkout main
git checkout fcd35d9fc03bf910151352d4c43ff8b5e497d4be -- esp.lua
git commit -m "revert: restore esp.lua from parent commit fcd35d9 (previous automation broke file)"
git push origin main
```

Or via the GitHub web UI: open `esp.lua` at commit `fcd35d9`, copy its raw contents, and paste them over the current `esp.lua` on `main`.

## Do Not Retry Automated Restore

Until the automation pipeline is given a tool capable of fetching the raw 66,831-character source content, retrying will only produce further placeholder commits. Please disable the automation for this repository until the manual restore above is completed.
