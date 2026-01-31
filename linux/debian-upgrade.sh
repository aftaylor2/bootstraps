#!/bin/bash
#
# Debian Distribution Upgrade Script
#
# Usage: sudo ./debian-upgrade.sh <target-codename>
# Example: sudo ./debian-upgrade.sh trixie
#
# Config file handling (--force-confdef and --force-confold):
#   --force-confdef  Use the package maintainer's version if you haven't
#                    modified the config file. If you have modified it,
#                    fall back to the next option.
#   --force-confold  Keep your existing config file when there's a conflict
#                    between your version and the maintainer's new version.
#
# Combined effect: Unchanged configs get updated automatically, while your
# customized configs (sshd_config, nginx, etc.) are preserved. New maintainer
# versions are saved as .dpkg-dist files for manual review:
#   find /etc -name "*.dpkg-dist"
#

set -e

TARGET="$1"

if [ -z "$TARGET" ]; then
  echo "Usage: $0 <codename>"
  echo "Example: $0 trixie"
  exit 1
fi

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (sudo)"
  exit 1
fi

# Detect current codename
CURRENT=$(grep -oP '(?<=VERSION_CODENAME=).*' /etc/os-release)
echo "Current: $CURRENT"
echo "Target:  $TARGET"
echo ""

read -p "Continue with upgrade? [y/N] " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  exit 0
fi

echo "==> Updating current system..."
apt update
apt upgrade -y
apt full-upgrade -y
apt autoremove -y

echo "==> Backing up sources.list..."
cp /etc/apt/sources.list /etc/apt/sources.list.${CURRENT}.bak

echo "==> Updating sources to $TARGET..."
sed -i "s/$CURRENT/$TARGET/g" /etc/apt/sources.list
for f in /etc/apt/sources.list.d/*.list; do
  [ -f "$f" ] && sed -i "s/$CURRENT/$TARGET/g" "$f"
done

echo "==> Fetching new package lists..."
apt update

echo "==> Performing minimal upgrade..."
apt upgrade --without-new-pkgs -y -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold

echo "==> Performing full upgrade..."
apt full-upgrade -y -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold

echo "==> Cleaning up..."
apt autoremove -y

echo ""
echo "Upgrade complete. Reboot with: sudo reboot"
