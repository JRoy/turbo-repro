#!/bin/sh
set -eu

rm -rf out node_modules

# 1. The root lockfile is valid: a frozen install succeeds.
bun install --frozen-lockfile

# 2. Prune the "app" workspace for docker. This succeeds.
rm -rf out
bunx turbo@2.10.4 prune app --docker >/dev/null

# 3. turbo's pruned out/json/bun.lock contains extraneous entries (nested chalk
#    under @expo/cli/ora, pulled in via the "mobile" workspace's eas-cli) that
#    bun's lockfile "clean" pass removes. A frozen install in out/json therefore
#    fails: "Clean lockfile: X packages - Y packages" with X != Y, followed by
#    "lockfile had changes, but lockfile is frozen".
echo "--- frozen install in out/json (expected to FAIL) ---"
(cd out/json && bun install --frozen-lockfile --lockfile-only --ignore-scripts --verbose 2>&1 \
  | grep -E "Clean lockfile|lockfile had changes") || true

# 4. The same failure in the exact CI image (bun 1.3.13):
echo "--- same failure in oven/bun:1.3.13-alpine ---"
docker run --rm -v "$PWD/out/json":/app -w /app oven/bun:1.3.13-alpine \
  sh -c "bun install --frozen-lockfile --ignore-scripts" || true
