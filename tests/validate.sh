#!/usr/bin/env bash
set -euo pipefail
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
validator="${WEBSERVICES_MODULE_CONTRACT_VALIDATOR:-}"
if [ -z "$validator" ]; then
  for candidate in     "$repo_root/../../sso-stack-generator/scripts/modules/module-contract.sh"     "$repo_root/../sso-stack-generator/scripts/modules/module-contract.sh"; do
    if [ -x "$candidate" ]; then
      validator="$candidate"
      break
    fi
  done
fi
[ -n "$validator" ] || { printf '[module-contract] set WEBSERVICES_MODULE_CONTRACT_VALIDATOR or keep sso-stack-generator next to modules workspace\n' >&2; exit 1; }
rg -q '^is_user_creation_disabled: false$' "$repo_root/stack.config/donetick/selfhosted.yaml" || {
  printf '[module-contract] Donetick must permit Keycloak first-login provisioning in selfhosted.yaml\n' >&2
  exit 1
}
rg -q '^      DT_IS_USER_CREATION_DISABLED: "false"$' "$repo_root/stack.runtime.yaml" || {
  printf '[module-contract] Donetick runtime and mounted config disagree on first-login provisioning\n' >&2
  exit 1
}
exec "$validator" validate "$repo_root"
