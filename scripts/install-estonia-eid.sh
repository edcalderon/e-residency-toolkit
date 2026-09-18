#!/bin/bash
# Estonia e-Residency / DigiDoc4 one-shot installer (Ubuntu + Linux Mint)
# Replicates the reference setup documented in docs/SETUP-LINUX-MINT.md
# Official source: https://installer.id.ee/media/install-scripts/install-open-eid.sh
# Usage: chmod +x install-estonia-eid.sh && ./install-estonia-eid.sh
set -euo pipefail

echo "=== Estonia eID installer (open-eid + pcscd + web-eid) ==="

if [ "$(id -u)" -eq 0 ]; then
  echo "ERROR: run as normal user (not root). sudo will be asked when needed."
  exit 2
fi
command -v sudo >/dev/null || { echo "ERROR: install sudo + add user to sudo group first."; exit 3; }
command -v lsb_release >/dev/null || sudo apt update && sudo apt install -y lsb-release

DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
RELEASE=$(lsb_release -rs)
CODENAME=$(lsb_release -cs)
echo "Detected: $DISTRO $RELEASE ($CODENAME)"

# Map distro -> RIA repo codename (mirrors official install-open-eid.sh)
RIA_CODENAME=""
case "$DISTRO" in
  ubuntu|neon|zorin|tuxedo|pop)
    case "$CODENAME" in
      jammy|noble|resolute) RIA_CODENAME="$CODENAME" ;;
      *) echo "WARN: $CODENAME not officially supported, falling back to resolute."; RIA_CODENAME="resolute" ;;
    esac
    ;;
  linuxmint)
    case "$RELEASE" in
      22*) RIA_CODENAME="noble" ;;
      21*) RIA_CODENAME="jammy" ;;
      *) echo "ERROR: Linux Mint $RELEASE not supported (need 21.x or 22.x)."; exit 4 ;;
    esac
    echo "Mint $RELEASE -> using Ubuntu repo '$RIA_CODENAME' (expected, official script does the same)."
    ;;
  debian)
    case "$CODENAME" in
      trixie) RIA_CODENAME="noble" ;;
      bookworm) RIA_CODENAME="jammy" ;;
      *) echo "ERROR: Debian $CODENAME not supported."; exit 4 ;;
    esac
    sudo apt install -y apt-transport-https
    ;;
  *)
    echo "ERROR: $DISTRO not supported. Use Ubuntu 22.04/24.04 or Mint 21/22."
    exit 4
    ;;
esac

# --- Option A: prefer official script if downloadable (most faithful) ---
if command -v wget >/dev/null || command -v curl >/dev/null; then
  TMP=/tmp/install-open-eid.sh
  echo "Downloading official installer to $TMP ..."
  if command -v wget >/dev/null; then
    wget -O "$TMP" https://installer.id.ee/media/install-scripts/install-open-eid.sh || true
  else
    curl -fsSL https://installer.id.ee/media/install-scripts/install-open-eid.sh -o "$TMP" || true
  fi
  if [ -s "$TMP" ]; then
    echo "Running official install-open-eid.sh (answer Y + ENTER when asked)..."
    sh "$TMP"
    echo "Official script done. Ensuring pcscd/libccid present..."
    sudo apt install -y pcscd libccid open-eid
    sudo systemctl enable --now pcscd || true
    echo "DONE via official script. Reboot, then run verify-estonia-eid.sh"
    exit 0
  fi
  echo "WARN: could not download official script, falling back to manual repo setup."
fi

# --- Option B: manual repo setup (identical result) ---
echo "Adding RIA key to /usr/share/keyrings/ria-repository.gpg ..."
# Fetch key the same way official script does (embedded key) via installer host:
wget -qO- https://installer.id.ee/media/ubuntu/dists/noble/InRelease 2>/dev/null | head -1 || true
# Use key from live reference machine approach: download dearmored key via script keyblock is complex,
# so pull the key via the official install script key if network allows, else reuse existing file.
if [ ! -f /usr/share/keyrings/ria-repository.gpg ]; then
  echo "Fetching RIA signing key..."
  # The official script embeds the key; simplest reliable fetch: re-download script and extract via gpg
  echo "Please run with network ON. Falling back to apt-key style fetch failed — download install-open-eid.sh manually:"
  echo "  wget https://installer.id.ee/media/install-scripts/install-open-eid.sh -O /tmp/install-open-eid.sh && sh /tmp/install-open-eid.sh"
  exit 5
fi

echo "Adding APT source for '$RIA_CODENAME' ..."
echo "deb [signed-by=/usr/share/keyrings/ria-repository.gpg] https://installer.id.ee/media/ubuntu/ $RIA_CODENAME main" | sudo tee /etc/apt/sources.list.d/ria-repository.list

echo "Installing: open-eid pcscd libccid ..."
sudo apt update
sudo apt install -y open-eid pcscd libccid

echo "Enabling pcscd ..."
sudo systemctl enable --now pcscd || true

if [ -x /usr/bin/pkcs11-register ]; then
  /usr/bin/pkcs11-register --skip-chrome=off --skip-firefox=off || true
fi

echo ""
echo "DONE. Reboot, plug in card reader + ID-card, then run ./verify-estonia-eid.sh"
