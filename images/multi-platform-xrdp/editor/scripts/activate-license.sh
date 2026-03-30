#!/bin/bash
set -euo pipefail

LICENSE_ROOT="/home/unity/.local/share/unity3d/Unity"
LICENSE_FILE="${LICENSE_ROOT}/Unity_lic.ulf"

if [ -z "${UNITY_LICENSE:-}" ]; then
  echo "[license] UNITY_LICENSE is empty. Falling back to manual GUI activation."
  exit 0
fi

mkdir -p "${LICENSE_ROOT}"

# Accept direct XML payload or base64-encoded XML payload.
if echo "${UNITY_LICENSE}" | grep -q "<?xml"; then
  printf '%s\n' "${UNITY_LICENSE}" > "${LICENSE_FILE}"
else
  if ! printf '%s' "${UNITY_LICENSE}" | base64 -d > "${LICENSE_FILE}" 2>/dev/null; then
    echo "[license] UNITY_LICENSE is not valid XML or base64 XML."
    exit 1
  fi
fi

if ! grep -q "<DeveloperData>\|<License" "${LICENSE_FILE}"; then
  echo "[license] Generated license file does not look valid."
  exit 1
fi

chown -R unity:unity /home/unity/.local/share/unity3d
chmod 600 "${LICENSE_FILE}"

echo "[license] Unity license written to ${LICENSE_FILE}."
