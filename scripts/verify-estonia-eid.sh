#!/bin/bash
# Verify Estonia eID / DigiDoc4 setup. Exit 0 = healthy, non-zero = issues found.
# Usage: ./verify-estonia-eid.sh
PASS=0; FAIL=0
ok()   { echo "  [OK] $1"; PASS=$((PASS+1)); }
bad()  { echo "  [FAIL] $1"; FAIL=$((FAIL+1)); }

echo "=== 1. OS ==="
lsb_release -d 2>/dev/null || bad "lsb_release missing"
echo "  codename: $(lsb_release -cs 2>/dev/null)"

echo "=== 2. RIA repo ==="
if grep -rh "installer.id.ee" /etc/apt/sources.list.d/ 2>/dev/null | grep -q .; then
  ok "$(grep -rh installer.id.ee /etc/apt/sources.list.d/ | head -1)"
else bad "RIA repo missing in /etc/apt/sources.list.d/"; fi
[ -f /usr/share/keyrings/ria-repository.gpg ] && ok "RIA key present" || bad "RIA key missing"

echo "=== 3. Packages ==="
for p in open-eid qdigidoc4 web-eid web-eid-chrome web-eid-firefox web-eid-native opensc opensc-pkcs11 pcscd libccid libdigidocpp1; do
  if dpkg -s "$p" >/dev/null 2>&1; then ok "$p $(dpkg-query -W -f='${Version}' "$p" 2>/dev/null)"; else bad "$p NOT installed"; fi
done

echo "=== 4. pcscd daemon ==="
if systemctl is-active --quiet pcscd; then ok "pcscd running"; else bad "pcscd not running (sudo systemctl enable --now pcscd)"; fi
command -v qdigidoc4 >/dev/null && ok "qdigidoc4 in PATH ($(command -v qdigidoc4))" || bad "qdigidoc4 missing"
command -v digidoc-tool >/dev/null && ok "digidoc-tool present" || bad "digidoc-tool missing"

echo "=== 5. Reader + card ==="
if command -v opensc-tool >/dev/null; then
  READERS=$(opensc-tool --list-readers 2>&1)
  echo "  $READERS" | head -5
  echo "$READERS" | grep -qi "no .* readers" && bad "no reader plugged in (plug in USB reader)" || ok "reader detected"
else bad "opensc-tool missing"; fi
lsusb 2>/dev/null | grep -i -E "acr|omnikey|identiv|scr|cherry|reader|072f|04e6|0b97" && ok "reader visible in lsusb" || echo "  [INFO] no obvious reader in lsusb — ok if none plugged in"

echo "=== 6. Browser native messaging ==="
[ -f /etc/chromium/native-messaging-hosts/eu.webeid.json ] && ok "chromium native host" || bad "chromium native host missing"
[ -f /usr/share/google-chrome/extensions/ncibgoaomkmdpilpocfeponihegamlic.json ] && ok "chrome extension pin" || bad "chrome extension pin missing"
[ -f /usr/lib/mozilla/native-messaging-hosts/eu.webeid.json ] && ok "firefox native host" || bad "firefox native host missing"
[ -f /usr/lib/x86_64-linux-gnu/opensc-pkcs11.so ] && ok "opensc-pkcs11.so present" || bad "opensc-pkcs11.so missing"

echo ""
echo "=== RESULT: $PASS ok, $FAIL fail ==="
[ "$FAIL" -eq 0 ] && echo "Healthy. Open DigiDoc4, insert card, test sign + https://web-eid.eu" || echo "Fix FAIL lines, then re-run. See README.md §8."
exit $FAIL
