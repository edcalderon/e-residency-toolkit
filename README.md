# e-Residency Toolkit — Estonia DigiDoc4 on Linux Mint / Ubuntu

Replicable setup for **Estonian e-Residency / Digi-ID / ID-card** on **Linux Mint 21/22 and Ubuntu 22.04/24.04**: DigiDoc4 client, smart-card stack, and Web eID browser integration — from zero to signing in ~5 minutes.

> **Focus:** Linux Mint (maps to Ubuntu repos). Ubuntu instructions work as-is; other Debian derivatives noted where applicable.

## Quick start

```bash
git clone https://github.com/<your-user>/e-residency-toolkit.git
cd e-residency-toolkit
chmod +x scripts/*.sh
./scripts/install-estonia-eid.sh
./scripts/verify-estonia-eid.sh
```

Reboot, plug in your USB smart-card reader + ID-card, then open DigiDoc4 (`qdigidoc4`).

Full walkthrough: [`docs/SETUP-LINUX-MINT.md`](docs/SETUP-LINUX-MINT.md) · Known-good versions: [`docs/SNAPSHOT.md`](docs/SNAPSHOT.md)

## What's inside

| Path | Purpose |
|---|---|
| `docs/SETUP-LINUX-MINT.md` | Full guide: hardware, install, browsers (incl. Firefox snap caveat), first-use checklist, troubleshooting, update/remove |
| `scripts/install-estonia-eid.sh` | One-shot installer (wraps official RIA script, auto-maps Mint→Ubuntu repos) |
| `scripts/verify-estonia-eid.sh` | Health check: repo, packages, `pcscd`, reader, browser native-messaging |
| `docs/SNAPSHOT.md` | Version snapshot of a verified-working machine |

## Requirements

- Linux Mint 21/22 or Ubuntu 22.04/24.04 (see guide for others)
- e-Resident Digi-ID / ID-card + PIN envelopes
- CCID USB smart-card reader (e.g. Identiv, ACS, OMNIKEY — details in guide)
- `sudo` access + internet

## Disclaimer — read before use

- **Unofficial community guide. Not affiliated with, endorsed, or supported by** the Estonian state, the Police and Border Guard Board, RIA (Information System Authority), SK ID Solutions, or the e-Residency programme. Official docs: https://www.id.ee/en/ — in case of conflict, the official docs win.
- **No warranty.** Provided "as is" under the MIT license. You run the scripts at your own risk; review them first (`scripts/` is short and commented).
- **Security:** your PINs and private keys **never leave the card** and are never asked for, stored, or transmitted by anything in this repo. Never share PIN1/PIN2/PUK, card photos, certificate exports, or signed personal documents. Nothing in this repo contains personal data — keep it that way in issues/PRs (no names, ID codes, serials, logs with personal info).
- **Scope:** desktop Linux setup automation only. It does not grant e-Residency, issue cards, or bypass any Estonian government process.
- Scripts add the official RIA APT repo (`https://installer.id.ee/media/ubuntu`) and install the official `open-eid` packages — i.e. the same software the state distributes, just automated for Mint.

## Contributing

PRs welcome — especially Mint/Ubuntu version mappings, reader compatibility notes, and Firefox/Chrome troubleshooting. Please don't include personal data, machine-specific identifiers, or screenshots showing names/ID codes.
