#!/usr/bin/env bash
# build-signed.sh — Build, sign, notarize, and package SnapNote as a DMG
# Usage: bash scripts/build-signed.sh [version]
# Example: bash scripts/build-signed.sh 0.1.2

set -euo pipefail

VERSION="${1:-0.1.2}"
SCHEME="SnapNote"
BUNDLE_ID="dev.garibong.SnapNote"
SIGNING_IDENTITY="Developer ID Application: Hahm Dong-Gi (R6DKRR4PG6)"
TEAM_ID="R6DKRR4PG6"
ASC_KEY_ID="LFUR5PS25U"
ASC_ISSUER_ID="69a6de79-c55f-47e3-e053-5b8c7c11a4d1"
ASC_KEY_PATH="$HOME/.appstoreconnect/private_keys/AuthKey_${ASC_KEY_ID}.p8"

BUILD_DIR="/tmp/snapnote-signed-build"
STAGE_DIR="/tmp/snapnote-dmg-stage"
DIST_DIR="$(dirname "$0")/../dist"
APP_PATH="$BUILD_DIR/Build/Products/Release/SnapNote.app"
DMG_PATH="$DIST_DIR/SnapNote-${VERSION}.dmg"

echo "==> [1/6] Generating Xcode project"
xcodegen generate

echo "==> [2/6] Building Release (signed)"
xcodebuild \
  -scheme "$SCHEME" \
  -configuration Release \
  -destination 'platform=macOS' \
  -derivedDataPath "$BUILD_DIR" \
  CODE_SIGN_IDENTITY="$SIGNING_IDENTITY" \
  CODE_SIGN_STYLE=Manual \
  DEVELOPMENT_TEAM="$TEAM_ID" \
  OTHER_CODE_SIGN_FLAGS="--timestamp" \
  build 2>&1 | tail -20

echo "==> [3/6] Verifying signature"
codesign --verify --deep --strict --verbose=2 "$APP_PATH"
spctl --assess --type exec --verbose "$APP_PATH" 2>&1 || true  # will fail before notarization — expected

echo "==> [4/6] Notarizing"
NOTARIZE_LOG=$(xcrun notarytool submit "$APP_PATH" \
  --key "$ASC_KEY_PATH" \
  --key-id "$ASC_KEY_ID" \
  --issuer "$ASC_ISSUER_ID" \
  --wait 2>&1)
echo "$NOTARIZE_LOG"

# Extract submission ID and check status
SUBMISSION_ID=$(echo "$NOTARIZE_LOG" | grep "id:" | head -1 | awk '{print $2}')
STATUS=$(echo "$NOTARIZE_LOG" | grep "status:" | tail -1 | awk '{print $2}')

if [[ "$STATUS" != "Accepted" ]]; then
  echo "❌ Notarization failed (status: $STATUS)"
  if [[ -n "$SUBMISSION_ID" ]]; then
    echo "--- Notarization log ---"
    xcrun notarytool log "$SUBMISSION_ID" \
      --key "$ASC_KEY_PATH" \
      --key-id "$ASC_KEY_ID" \
      --issuer "$ASC_ISSUER_ID" 2>&1 || true
  fi
  exit 1
fi

echo "==> [5/6] Stapling notarization ticket"
xcrun stapler staple "$APP_PATH"
spctl --assess --type exec --verbose "$APP_PATH"

echo "==> [6/6] Creating DMG"
mkdir -p "$DIST_DIR"
rm -rf "$STAGE_DIR"
mkdir -p "$STAGE_DIR"
cp -R "$APP_PATH" "$STAGE_DIR/"
ln -sf /Applications "$STAGE_DIR/Applications"

hdiutil create \
  -volname "SnapNote" \
  -srcfolder "$STAGE_DIR" \
  -ov \
  -format UDZO \
  "$DMG_PATH"

rm -rf "$STAGE_DIR"

echo ""
echo "✅ Done: $DMG_PATH"
echo "   $(du -sh "$DMG_PATH" | cut -f1)"
