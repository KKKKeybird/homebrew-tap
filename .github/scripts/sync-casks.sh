#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$repo_root"

update_cask() {
  local token="$1"
  local version="$2"
  local sha256="$3"
  local file="Casks/${token}.rb"
  local current_version

  if [[ ! "$sha256" =~ ^[0-9a-f]{64}$ ]]; then
    echo "Invalid SHA-256 for ${token}: ${sha256}" >&2
    exit 1
  fi

  current_version="$(sed -n 's/^  version "\(.*\)"$/\1/p' "$file")"
  if [[ "$current_version" == "$version" ]]; then
    echo "${token} is current at ${version}."
    return
  fi

  TOKEN="$token" VERSION="$version" SHA256="$sha256" ruby -pi -e '
    gsub(/^  version ".*"$/, %(  version "#{ENV.fetch("VERSION")}"))
    gsub(/^  sha256 ".*"$/, %(  sha256 "#{ENV.fetch("SHA256")}"))
  ' "$file"
  echo "Updated ${token}: ${current_version} -> ${version}"
}

sync_github_cask() {
  local token="$1"
  local upstream="$2"
  local tag_prefix="$3"
  local asset_template="$4"
  local release_json tag version asset_name asset_url digest sha256

  release_json="$(gh api "repos/${upstream}/releases/latest")"
  tag="$(jq -r '.tag_name' <<<"$release_json")"
  version="${tag#"$tag_prefix"}"
  asset_name="${asset_template//\{version\}/$version}"
  asset_url="$(jq -r --arg name "$asset_name" '.assets[] | select(.name == $name) | .browser_download_url' <<<"$release_json")"
  digest="$(jq -r --arg name "$asset_name" '.assets[] | select(.name == $name) | .digest // empty' <<<"$release_json")"

  if [[ -z "$asset_url" ]]; then
    echo "Missing ${upstream} release asset: ${asset_name}" >&2
    exit 1
  fi

  if [[ "$digest" == sha256:* ]]; then
    sha256="${digest#sha256:}"
  else
    sha256="$(curl -fsSL "$asset_url" | sha256sum | cut -d ' ' -f 1)"
  fi

  update_cask "$token" "$version" "$sha256"
}

sync_github_cask "moonlight-vplus" "qiin2333/moonlight-qt" "v" "Moonlight-VPlus-{version}-arm64.dmg"
sync_github_cask "scriptplayerplus" "sioaeko/scriptplayer-plus" "v" "ScriptPlayerPlus-{version}-arm64-mac.dmg"
sync_github_cask "xenolauncher" "m5kro/Xenolauncher" "" "Xenolauncher-arm64.zip"

tmog_json="$(curl -fsSL https://www.tmog.org/downloads/release.json)"
tmog_version="$(jq -r '"\(.version),\(.build)"' <<<"$tmog_json")"
tmog_sha256="$(jq -r '.sha256' <<<"$tmog_json")"
update_cask "tmog" "$tmog_version" "$tmog_sha256"

haima_json="$(curl -fsSL https://pc-rel.haimawan.com/cloud/app/version/latest \
  -H 'Content-Type: application/json' \
  -d '{"channelCode":"haimayun","clientType":"MAC","platform":"mac_arm"}')"
haima_version="$(jq -r '.result.versionName // empty' <<<"$haima_json")"
haima_url="$(jq -r '.result.pkgUrl // empty' <<<"$haima_json")"
current_haima_version="$(sed -n 's/^  version "\(.*\)"$/\1/p' Casks/haima-cloud.rb)"

if [[ -z "$haima_version" || -z "$haima_url" ]]; then
  echo "Haima release API did not return an arm64 macOS release." >&2
  exit 1
fi

if [[ "$current_haima_version" == "$haima_version" ]]; then
  echo "haima-cloud is current at ${haima_version}."
else
  haima_sha256="$(curl -fsSL "$haima_url" | sha256sum | cut -d ' ' -f 1)"
  update_cask "haima-cloud" "$haima_version" "$haima_sha256"
fi
