# SNAPSHOT — reference machine (known-good)

Captured 2026-09-18 on a reference machine (Linux Mint 22.3 Zena = Ubuntu noble).

## OS
- `PRETTY_NAME="Linux Mint 22.3"`, `UBUNTU_CODENAME=noble`, kernel `7.0.0-31-generic`, Wayland/GNOME

## APT source
- File: `/etc/apt/sources.list.d/ria-repository.list`
- Content: `deb [signed-by=/usr/share/keyrings/ria-repository.gpg] https://installer.id.ee/media/ubuntu/ noble main`
- Key: `/usr/share/keyrings/ria-repository.gpg` (RIA Software Signing Key <signing@ria.ee>)

## Installed versions (dpkg)
- `open-eid 26.7.0.8427-2404` (metapackage)
- `qdigidoc4 4.11.0.5421-2404`
- `libdigidocpp1 4.5.0.8428-2404`, `libdigidocpp-common`, `libdigidocpp-tools`
- `opensc 0.27.1-0RIA3`, `opensc-pkcs11 0.27.1-0RIA3`
- `web-eid 2.10.0.934-2404`, `web-eid-chrome`, `web-eid-firefox`, `web-eid-native`
- `pcscd 2.0.3-1build1`, `libpcsclite1 2.0.3-1build1`, `libccid 1.5.5-1`

## Daemons / binaries
- `pcscd.service` active (triggered by `pcscd.socket`)
- `/usr/bin/qdigidoc4`, `/usr/bin/digidoc-tool`, `/usr/bin/eidenv`, `/usr/bin/web-eid`, `/usr/bin/pkcs11-register`
- `/usr/lib/x86_64-linux-gnu/opensc-pkcs11.so`
- `opensc-tool --list-readers` → "No smart card readers found." (no reader plugged in at capture time)

## Browser integration
- `/etc/chromium/native-messaging-hosts/eu.webeid.json` → `/usr/bin/web-eid`
- `/usr/share/google-chrome/extensions/ncibgoaomkmdpilpocfeponihegamlic.json` (Chrome/Brave)
- `/usr/lib/mozilla/native-messaging-hosts/eu.webeid.json` + `{e68418bc-f2b0-4459-a9ea-3e72b6751b07}.xpi` (Firefox)
- Browsers present: Chrome 152, Brave 1.94, Firefox 155, Chromium

## Notes
- Mint 22 maps to Ubuntu `noble` repo (official script prints "not officially supported" warning — expected, works).
- ID-software 26.7 release notes: https://www.id.ee/en/article/id-software-versions-info-release-notes
