#!/usr/bin/env bash
# Builds the signed Android App Bundle for the Play Store.
#
# The signing password is never written to a file. Godot reads the upload key
# from these environment variables, so export_presets.cfg stays free of secrets
# and safe to commit.
#
# Usage:  scripts/build-release.sh
set -euo pipefail

KEYSTORE="${KEYSTORE:-$HOME/devs/JD/keys/casserole-upload.jks}"
ALIAS="${ALIAS:-upload}"

[ -f "$KEYSTORE" ] || { echo "Keystore introuvable: $KEYSTORE" >&2; exit 1; }
source "$HOME/devs/JD/tools/env.sh"

read -rsp "Mot de passe de la cle de publication: " PASSWORD
echo

export GODOT_ANDROID_KEYSTORE_RELEASE_PATH="$KEYSTORE"
export GODOT_ANDROID_KEYSTORE_RELEASE_USER="$ALIAS"
export GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD="$PASSWORD"

cd "$(dirname "$0")/.."
mkdir -p build
godot4 --headless --path . --export-release "Android Release" build/casserole.aab

echo
echo "Bundle: $(ls -lh build/casserole.aab | awk '{print $5, $9}')"
echo "Signature:"
"$ANDROID_HOME"/build-tools/36.1.0/apksigner verify --print-certs --min-sdk-version 24 \
  build/casserole.aab 2>/dev/null | grep -i "SHA-256" || \
  echo "  (un AAB est signe par jarsigner: verifier avec 'jarsigner -verify -verbose:summary build/casserole.aab')"
