#!/usr/bin/env bash
# Verify that both lockfile root versions match package.json.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
node -e '
const pkg = require("./package.json");
const lock = require("./package-lock.json");
if (!pkg.version || lock.version !== pkg.version || lock.packages?.[""].version !== pkg.version) {
    console.error("Version mismatch between package.json and package-lock.json");
    process.exit(1);
}
console.log(`Package and lockfile versions match: ${pkg.version}`);
'
