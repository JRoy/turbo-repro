#!/bin/sh
set -eu

rm -rf out node_modules

# Root lockfile is valid.
bun install --frozen-lockfile

# Without --production the pruned output installs fine.
rm -rf out
bunx turbo@2.10.5-canary.4 prune app --docker >/dev/null
(cd out/json && bun install --frozen-lockfile --ignore-scripts >/dev/null 2>&1 && echo "plain prune: OK")

# With --production the pruned bun.lock still lists the root devDependency
# "tooling": "workspace:*" but the tooling workspace itself is excluded,
# so bun cannot parse the lockfile.
rm -rf out
bunx turbo@2.10.5-canary.4 prune app --docker --production >/dev/null
(cd out/json && bun install --frozen-lockfile --ignore-scripts) || true
