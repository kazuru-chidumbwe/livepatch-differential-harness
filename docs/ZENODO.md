# Zenodo archive — LivepatchDiff

**Status:** Deposit package ready · mint when `ZENODO_TOKEN` is set (or publish via Zenodo↔GitHub on Release `v0.1.1`).

**Cite pin:** `v0.1.1`  
**GitHub tree (SCP C2):** https://github.com/kazuru-chidumbwe/livepatch-differential-harness/tree/v0.1.1  

**Version DOI:** _pending mint_  
**Concept DOI:** _pending mint_

## SCP metadata

| Field | Value |
| --- | --- |
| C1 | `v0.1.1` |
| C2 | GitHub tree URL above (not Zenodo) |
| C3 | Zenodo version DOI after publish |

## Mint (API)

```powershell
$TOKEN = $env:ZENODO_TOKEN  # https://zenodo.org/account/settings/applications/
$meta = Get-Content '.\.zenodo.json' -Raw
# Prefer uploading the GitHub Release source zip for v0.1.1, or a local archive of that tag.
$dep = Invoke-RestMethod -Method Post -Uri 'https://zenodo.org/api/deposit/depositions' `
  -Headers @{Authorization = "Bearer $TOKEN"; 'Content-Type'='application/json'} -Body '{}'
$id = $dep.id
$bucket = $dep.links.bucket
# Example: download release zip then PUT to $bucket
Invoke-RestMethod -Method Put -Uri "https://zenodo.org/api/deposit/depositions/$id" `
  -Headers @{Authorization = "Bearer $TOKEN"; 'Content-Type'='application/json'} `
  -Body (@{metadata=(Get-Content '.\.zenodo.json' -Raw | ConvertFrom-Json)} | ConvertTo-Json -Depth 8)
Invoke-RestMethod -Method Post -Uri "https://zenodo.org/api/deposit/depositions/$id/actions/publish" `
  -Headers @{Authorization = "Bearer $TOKEN"}
```

Or: enable the repo under Zenodo → GitHub, then publish Release `v0.1.1` (or click Sync).

After DOI exists, paste into this file, `CITATION.cff`, and the SCP manuscript Code metadata C3.
