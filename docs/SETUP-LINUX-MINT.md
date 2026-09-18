# Estonia e-Residency + DigiDoc4 — Replicable Setup Guide (Linux)

> Reference machine (verified working 2026-09-18):
> - **OS:** Linux Mint 22.3 Zena (= Ubuntu 24.04 `noble` base), kernel 7.0.0-31-generic, Wayland/GNOME
> - **ID-software:** `open-eid 26.7.0.8427-2404`, `qdigidoc4 4.11.0.5421-2404`, `libdigidocpp 4.5.0.8428`, `opensc 0.27.1-0RIA3`, `web-eid 2.10.0.934-2404`, `pcscd 2.0.3`, `libccid 1.5.5`
> - **Browsers tested:** Chrome 152, Brave 1.94, Firefox 155, Chromium
> - **Repo:** `deb [signed-by=/usr/share/keyrings/ria-repository.gpg] https://installer.id.ee/media/ubuntu/ noble main`
>
> Goal: replicate this exact working stack on any fresh Ubuntu / Mint machine in ~5 minutes.

Official docs: https://www.id.ee/en/article/ubuntu-id-software-installation-updating-and-removal

---

## 1. What you need (hardware)

1. **e-Resident Digi-ID / ID-card** + PIN envelopes (PIN1 = auth, PIN2 = sign, PUK = unblock).
2. **USB smart-card reader** (CCID-compliant). Any of these works plug-and-play with `libccid`:
   - Identiv uTrust 2700 R / SCR3310v2
   - ACS ACR39U / ACR38U
   - HID OMNIKEY 3021 / 3121
   - Cherry ST-2000
   - Explanation: no driver install needed — Ubuntu's `libccid + pcscd` already covers all CCID readers.
3. USB port. No Bluetooth readers needed.

> The reference machine had **no card reader plugged in** at capture time (`opensc-tool --list-readers` → "No smart card readers found"). Plug yours in before step 6. A FIDO2 security key is **not** a substitute for the ID-card reader.

## 2. What gets installed (software map)

| Component | Package | What it does |
|---|---|---|
| DigiDoc4 client (GUI) | `qdigidoc4` | Sign / verify `.asice/.bdoc/.ddoc`, encrypt, manage PINs |
| CLI tools | `libdigidocpp-tools` (`digidoc-tool`, `cbrtc`) | Script signing/verification |
| Smart-card stack | `opensc`, `opensc-pkcs11`, `pcscd`, `libccid`, `libpcsclite1` | Talk to card + reader |
| Web auth/sign in browser | `web-eid`, `web-eid-chrome`, `web-eid-firefox`, `web-eid-native` | Native-messaging host + extensions for eesti.ee, banks, etc. |
| Meta-package | `open-eid` | Pulls all of the above together |
| Repo | `ria-repository.list` → `https://installer.id.ee/media/ubuntu` | RIA (Estonian Information System Authority) APT repo |

Browser extension IDs (pre-installed by the .deb, just enable them):
- Chrome / Brave / Chromium / Edge: `ncibgoaomkmdpilpocfeponihegamlic` ("Web eID")
- Firefox: `{e68418bc-f2b0-4459-a9ea-3e72b6751b07}.xpi` + AMO listing "Web eID"

## 3. Supported OS versions

Officially supported: **Ubuntu 22.04 jammy, 24.04 noble, 26.04 resolute** (see `install-open-eid.sh`).
Also works via mapping:
- **Linux Mint 22.x → use `noble` repo** (this is what this guide does)
- Linux Mint 21.x → use `jammy` repo
- Debian trixie → noble, bookworm → jammy (unofficial)

Check yours with: `lsb_release -a`. Mint 22.x reports codename `zena` (= Ubuntu `noble` repo); Mint 21.x reports `vanessa/vera/victoria/virginia` (= Ubuntu `jammy` repo). The installer script auto-maps this.

## 4. Fast replicate (new machine, 5 min)

On the **new** machine, from this folder:

```bash
git clone https://github.com/edcalderon/e-residency-toolkit.git
cd e-residency-toolkit
chmod +x scripts/*.sh
./scripts/install-estonia-eid.sh
./scripts/verify-estonia-eid.sh
```

What the installer does (same as official `install-open-eid.sh` + Mint fix):
1. Adds RIA key to `/usr/share/keyrings/ria-repository.gpg`
2. Adds `deb [signed-by=...] https://installer.id.ee/media/ubuntu/ noble main` (auto-detects `jammy`/`noble`)
3. `apt update && apt install open-eid pcscd libccid`
4. Enables + starts `pcscd`
5. Runs `pkcs11-register` for Chrome + Firefox for current user
6. Prints next steps (browser extensions, reboot, test)

Then **reboot**, plug in reader + card, and continue to §5–6.

### Manual method (if you don't want the script)

```bash
# 1. Download official script
wget https://installer.id.ee/media/install-scripts/install-open-eid.sh -O /tmp/install-open-eid.sh
sh /tmp/install-open-eid.sh
# Answer Y when asked. On Mint 22 it warns "not officially supported" and uses noble — that's expected, press ENTER then Y.
# 2. Ensure smart-card daemon present
sudo apt install -y pcscd libccid
sudo systemctl enable --now pcscd
```

## 5. Browser setup (required for eesti.ee / banks / Smart-ID portal)

### Chrome / Brave / Chromium / Edge (recommended — least friction)
1. Open `chrome://extensions/` (or `brave://extensions/`).
2. Enable **Web eID** (ID `ncibgoaomkmdpilpocfeponihegamlic`). If missing, install from Chrome Web Store → "Web eID".
3. The native host is already installed by the .deb at:
   - `/etc/chromium/native-messaging-hosts/eu.webeid.json`
   - `/usr/share/google-chrome/extensions/ncibgoaomkmdpilpocfeponihegamlic.json`
4. Test at https://web-eid.eu/ → "Test" or https://www.id.ee/en/article/test-your-id-card/

### Firefox — IMPORTANT snap caveat
Ubuntu ≥21.10 / Mint ships Firefox in ways that break PKCS#11:
- **Snap Firefox + Web eID sites (TARA, eesti.ee): works** after installing the AMO extension "Web eID" and accepting the consent popup.
- **Snap Firefox + old TLS-client-cert auth sites: DOES NOT work.** Fix = replace snap with deb:

```bash
snap remove --purge firefox
sudo apt remove --autoremove firefox   # WARNING: wipes history/bookmarks unless synced
sudo add-apt-repository ppa:mozillateam/ppa
# pin deb over snap (create /etc/apt/preferences.d/99mozillateamppa with):
# Package: firefox*  Pin: release o=LP-PPA-mozillateam  Pin-Priority: 501
# Package: firefox*  Pin: release o=Ubuntu              Pin-Priority: -1
sudo apt install -t 'o=LP-PPA-mozillateam' firefox
```

Full official Firefox section: https://www.id.ee/en/article/ubuntu-id-software-installation-updating-and-removal/#SNAP

After either Firefox flavor: install https://addons.mozilla.org/et/firefox/addon/web-eid-webextension/ → allow → consent on first auth/sign.

## 6. First use checklist (with card + reader)

1. `pcscd` running? `systemctl status pcscd --no-pager | head`
2. Reader detected? `opensc-tool --list-readers` should list your reader (not "No smart card readers found").
3. Open **DigiDoc4** (`qdigidoc4` from menu). Insert card → "My eID" tab shows name + cert validity.
4. Test sign: DigiDoc4 → Create container → add a .txt → Sign with PIN2 → save `.asice` → verify shows green check.
5. Test web: go to https://eesti.ee or https://web-eid.eu, choose "ID-card", enter PIN1 when Web eID popup appears.
6. PIN management: DigiDoc4 → My eID → change PIN1/PIN2/PUK. **3 wrong PINs = lock; PUK unlocks; PUK locked = go to PPA.**

## 7. Everyday commands (cheat sheet)

```bash
qdigidoc4 &                          # GUI
digidoc-tool sign --file doc.pdf -c doc.asice  # CLI sign (will prompt PIN2)
opensc-tool --list-readers           # reader present?
opensc-tool --reader 0 --name        # card present?
eidenv                               # OpenSC card info
web-eid --help                       # Web eID helper
sudo apt-get update && sudo apt-get upgrade  # update ID-software (official method)
```

File types: `.asice/.sce` (modern EU), `.bdoc`, `.ddoc` (legacy), `.cdoc` (encrypted). Verify anyone's signature by opening the container in DigiDoc4 — green = valid.

## 8. Troubleshooting (what actually breaks)

| Symptom | Fix |
|---|---|
| `No smart card readers found` | Plug reader, `sudo systemctl restart pcscd`, try another USB port, `lsusb` should show reader |
| Card not seen but reader seen | Re-seat card (chip up), `eidenv`, try `pcscd --foreground --debug` |
| DigiDoc4 shows old card data | Restart DigiDoc4, re-insert card (known bug fixed in 26.x, update) |
| Firefox: no consent dialog / auth fails | `sudo snap refresh`, delete `~/.local/share/flatpak/db/webextensions`, reboot; or switch to deb Firefox (§5) |
| Chrome: "native host not found" | Reinstall `sudo apt install --reinstall web-eid web-eid-chrome web-eid-native`, re-enable extension, restart browser |
| `apt update` GPG error for RIA repo | Re-add key: re-run `scripts/install-estonia-eid.sh` (it rewrites `/usr/share/keyrings/ria-repository.gpg`) |
| Wayland quirks | DigiDoc4 works on Wayland (this machine is Wayland). If PIN popup hides, bring DigiDoc4 to front. |

Logs: run `qdigidoc4` from terminal to see TSL/OpenSC debug lines; Web eID logs via browser extension console.

## 9. Update & remove (official)

```bash
sudo apt-get update && sudo apt-get upgrade   # update (do regularly — TSL/certs update this way)
# remove:
wget https://installer.id.ee/media/install-scripts/uninstall-open-eid.sh -O /tmp/uninstall-open-eid.sh
sh /tmp/uninstall-open-eid.sh
```

## 10. Replicate / backup notes

- To clone to another machine: **copy this whole `Estonia/` folder** (guide + scripts) via USB/Sync. No secrets inside — safe to copy.
- Nothing machine-specific is required except Ubuntu codename (`jammy`/`noble`) — the script auto-detects.
- PINs/keys **never leave the card** — nothing to export. Only backup: signed `.asice` files + this guide.
- Snapshot of this machine's exact versions: see `SNAPSHOT.md` in this folder.

## 11. Links

- Install/update/remove (Ubuntu): https://www.id.ee/en/article/ubuntu-id-software-installation-updating-and-removal
- OS support list: https://www.id.ee/en/article/operating-systems-supported-by-id-software/
- Test your card: https://www.id.ee/en/article/test-your-id-card/
- Installer script source: https://github.com/open-eid/linux-installer/blob/master/install-open-eid.sh
- Web eID: https://web-eid.eu/
- Release notes (26.7 = current here): https://www.id.ee/en/article/id-software-versions-info-release-notes
