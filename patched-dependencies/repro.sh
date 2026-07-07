#!/bin/sh
set -eu

rm -rf out node_modules

bun install --frozen-lockfile

rm -rf out
bunx turbo@2.10.4 prune app --docker >/dev/null

grep -A3 patchedDependencies out/json/package.json
ls out/json/patches 2>/dev/null || echo "patches/ not copied"

docker run --rm -v "$PWD/out/json":/app -w /app oven/bun:1.3.13-alpine \
  sh -c "bun install --frozen-lockfile --ignore-scripts" || true
